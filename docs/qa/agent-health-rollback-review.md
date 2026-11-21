# Rà soát agent: kiểm tra đúng cổng IIS và rollback khi HTTP/HTTPS thất bại

## Phạm vi và trạng thái

Đây là bản sửa đề xuất, chưa thay `C:\BanTinAgent\Update-BanTin.ps1`, chưa chạy Publish lên website thật, chưa bật task Production. Các thử nghiệm ghi tệp chỉ dùng TEMP. Website thật chỉ được đọc và kiểm tra bằng HTTP/HTTPS.

- Agent đang dùng: SHA-256 `e0fb38f022fa9613a23c72499c6c210e5e91aa7e1a942b5ae7ad32630156ede5`.
- Agent đề xuất: SHA-256 `4c6c6d2a6b6207e6a7c28e8c0c8e1e831dee43a36f1a02d349978c7ce20d9bbb`.
- Mốc mã nguồn nền: commit `28d9f1f4ab62cf6c62f08cbb781ab5e77b0c7638`.
- Sau thử nghiệm, hash agent đang dùng, index Production và `web.config` vẫn bằng trước khi thử.

## Dữ kiện đã kiểm chứng

| Quan sát | Bằng chứng | Kết luận trong phạm vi bằng chứng |
|---|---|---|
| Bộ phân giải tên trên TRAV13 trả `127.0.0.1` cho `bantin.trav.gov.vn` | `Resolve-DnsName -Type A` | URL HTTPS mặc định từ máy chủ đi vào loopback:443 |
| Site Started, webroot `C:\Web\bantin`, HTTP 80, HTTPS 8443 SNI | `Get-Website`, `Get-WebBinding` | Cổng 443 không phải binding HTTPS của site này |
| HTTPS 8443 trả 200 với xác thực chứng chỉ mặc định | `Invoke-WebRequest` trên số 19 | Lỗi kiểm tra hiện tại không đòi đổi chứng chỉ hoặc bỏ xác thực SSL |
| HTTPS mặc định 443 từ máy chủ báo lỗi tin cậy | Cùng lệnh nhưng không có `:8443` | Agent cũ kiểm tra sai cổng so với binding IIS hiện tại; chưa xác định lại dịch vụ trả chứng chỉ ở 443 trong lượt này |
| HTTPS công khai trả 200 | `curl.exe --resolve bantin.trav.gov.vn:443:113.164.228.22`, không dùng `--insecure` | Đường công khai 443 hoạt động khi kết nối đúng IP và giữ hostname/SNI |
| HTTP công khai 80 timeout | curl từ máy chủ và kiểm tra độc lập trước đó | Chưa xác nhận nguyên nhân; không tự sửa Firewall, DNS, NAT hoặc Binding |

Độ tin cậy cao cho các kết quả trên; đây không phải kiểm toán toàn bộ hạ tầng TLS. Không đọc hoặc xuất private key, PFX hoặc bí mật OAuth.

## Sửa đổi

- Đưa kiểm tra HTTP/HTTPS vào trong giao dịch sao lưu → chép → hash → health check. Lỗi sau khi chép sẽ khôi phục UPDATE, kiểm tra hash sau khôi phục và xóa đúng ADD của giao dịch.
- Kiểm tra cả status 200 và SHA-256 nội dung thực nhận để phát hiện cache/trang lỗi hoặc nội dung cũ dù HTTP trả 200.
- Kiểm tra HTTP nội bộ 80, HTTPS nội bộ 8443 và HTTPS công khai 443. Đích công khai được chọn cho riêng request bằng curl; không thay DNS, hosts hay SSL.
- Trước khi ghi, kiểm tra index hiện tại. Sao lưu toàn bộ webroot và xác minh hash từng tệp trước khi cập nhật. Giữ các backup và ghi kết quả rollback rõ ràng.
- Ghi Production bắt buộc câu duyệt chính xác, tag cụ thể và full SHA bằng manifest. Không có duyệt thì dừng trước khi tạo thư mục làm việc. Không bật tự động Production bằng task thăm dò.

## Kiểm thử Windows PowerShell 5.1

Runtime thật trên TRAV13: `5.1.17763.9376`. Cả **10/10** ca đạt với đúng hash agent đề xuất ở trên. Fixture release, response HTTP/curl và webroot được cô lập trong TEMP; chỉ đường dẫn webroot cố định được thay trong bản sao thử.

| Ca thử | Kết quả |
|---|---|
| Check không đổi website | Đạt, exit 0 |
| Cập nhật Preview mô phỏng thành công | Đạt, exit 0 |
| HTTP 500 sau chép | Rollback đạt, exit 1 |
| Lỗi tin cậy HTTPS sau chép | Rollback đạt, exit 1 |
| Timeout sau chép | Rollback đạt, exit 1 |
| Status 200 nhưng sai hash | Rollback đạt, exit 1 |
| HTTPS công khai thất bại | Rollback đạt, exit 1 |
| HTTPS công khai trả nội dung cũ | Rollback đạt, exit 1 |
| Production thiếu duyệt | Bị chặn đúng lý do, exit 1 |
| Production sai full SHA | Bị chặn đúng lý do, exit 1 |

Sau mỗi ca rollback: index cũ và tệp ngoài gói giữ nguyên; tệp ADD đã được gỡ; `web.config`, `admin` và snapshot vẫn đúng hash; backup được giữ lại. Bộ thử được thêm vào CI Windows.

Đã chạy thêm candidate ở `Mode Check -Channel Preview` trên máy chủ với WorkRoot riêng trong TEMP, release `preview-28d9f1f4ab62cf6c62f08cbb781ab5e77b0c7638`: exit 0, `changes=0`; index qua ba đường đều status 200 và hash `28f42c6fdf2a421c03a10947dd8cfdb5cbf357f52f2de2970a858b9eba3d7041`. Đây là kiểm tra thật, không ghi website.

Đối chiếu với bản sao lưu trước thử: toàn bộ 341 tệp gốc vẫn đúng hash. Trong thời gian thực hiện có thêm 6 tệp của số 17 (HTML và 5 SVG), ngoài phạm vi bản sửa này; giữ nguyên, không đưa vào commit và không quy kết nguồn tạo.

## Điều kiện trước khi vận hành

Người phụ trách cần duyệt cài thay agent ở `C:\BanTinAgent`; phạm vi ghi đã cấp trước đó chỉ bao gồm thư mục website Preview. Khi được phép: sao lưu agent cũ, đối chiếu hash candidate, cài và chạy Check dưới đúng tài khoản vận hành. Cài agent không kích hoạt Production.

Phạm vi health bắt buộc trong bản đề xuất là HTTP nội bộ và HTTPS nội bộ/công khai. HTTP công khai 80 chưa hoạt động trong các lần kiểm tra. Nếu chính sách yêu cầu HTTP công khai bắt buộc, cần giải quyết yêu cầu đó trước khi dùng MODE PUBLISH; không tự ý mở cổng hay sửa cấu hình bị cấm. Chỉ xuất bản bản tin khi có câu DUYỆT XUẤT BẢN gắn đúng phiên bản và SHA.
