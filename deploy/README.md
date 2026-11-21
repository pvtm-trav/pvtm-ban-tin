# Bản tin: Preview → duyệt → xuất bản có kiểm tra và rollback

Bản sửa này cần được duyệt cài đặt trước khi thay `C:\BanTinAgent\Update-BanTin.ps1`. Việc cài agent không phải duyệt xuất bản một số bản tin. Không tự bật Scheduled Task Production.

| Kênh | Release | Đích IIS | Điều kiện ghi |
|---|---|---|---|
| Preview | `preview-<40 ký tự SHA>`, prerelease | `C:\Web\bantin\ban-tin-moi` | Release và từng tệp đạt kiểm tra SHA-256 |
| Production | `bantin-<năm>.<số>-<12 ký tự SHA>` | `C:\Web\bantin` | Người dùng nói rõ **DUYỆT XUẤT BẢN**, gắn đúng toàn bộ SHA và release |

Agent không sửa IIS Binding, SSL, DNS, Firewall, không restart IIS hoặc recycle App Pool, không tự xóa backup. Gói và agent chặn `web.config`, `admin/`, `oauth/`, `ban-tin-moi/`. Những tệp website không thuộc gói được giữ nguyên. WorkRoot phải nằm ngoài website.

## Cách kiểm tra đúng trên máy chủ hiện tại

Đối chiếu thực tế trên TRAV13: `bantin.trav.gov.vn` phân giải thành `127.0.0.1`; binding HTTPS của site là `*:8443:bantin.trav.gov.vn`. Vì thế gọi `https://bantin.trav.gov.vn/` từ chính máy chủ đi vào cổng 443 trên loopback, không phải binding IIS của site. Đã kiểm tra thành công `https://bantin.trav.gov.vn:8443/` với xác thực chứng chỉ mặc định, không bỏ qua lỗi chứng chỉ.

Agent kiểm tra status 200 và SHA-256 của nội dung thực nhận qua ba đường:

| Đường kiểm tra | URL/đích kết nối | Xác thực |
|---|---|---|
| HTTP nội bộ | `http://bantin.trav.gov.vn:80/...` | Status 200 và hash nội dung |
| HTTPS nội bộ IIS | `https://bantin.trav.gov.vn:8443/...` | Xác thực chứng chỉ mặc định, status 200 và hash |
| HTTPS công khai | `https://bantin.trav.gov.vn/...`, kết nối `113.164.228.22:443` | `curl.exe --resolve` chỉ định kết nối cho riêng request, giữ hostname/SNI và xác thực chứng chỉ; kiểm tra status và hash |

`--resolve` không sửa hosts, DNS, binding hoặc SSL. Không dùng `--insecure`, không cài callback chấp nhận mọi chứng chỉ. Agent cần `curl.exe` có sẵn trên máy chủ. Các tham số `HealthHost`, `HealthHttpsPort`, `PublicAddress` chỉ điều chỉnh đích kiểm tra của tiến trình.

HTTP công khai cổng 80 hiện timeout; phạm vi kiểm tra bắt buộc của agent là HTTP nội bộ và HTTPS nội bộ/công khai như bảng trên. Không khẳng định HTTP công khai hoạt động. Nếu chính sách yêu cầu cả HTTP công khai, cần xác nhận và xử lý riêng trước khi xuất bản; việc đó không cho phép tự sửa Firewall, DNS hay Binding.

## Giao dịch cập nhật

1. Tải đúng release, kiểm tra channel/tag/full SHA, hash ZIP, danh sách đường dẫn và hash từng tệp. Từ chối đường dẫn ngoài đích, reparse point và cấu hình được bảo vệ.
2. Kiểm tra trang index hiện tại qua ba đường trước khi ghi website. `Mode Check` kết thúc tại đây và không sửa website. Nếu gói đã khớp, vẫn kiểm tra các trang HTML trước khi báo thành công.
3. Khi cần thay đổi, tạo backup mới: toàn bộ `C:\Web\bantin` vào `website-snapshot`, kiểm tra hash từng tệp; đồng thời giữ bản UPDATE và journal phục vụ rollback. Không xóa các backup cũ.
4. Chép các tệp được phép, index sau cùng; kiểm tra hash trên đĩa và mọi trang HTML cấp gốc trong manifest qua ba đường nêu trên.
5. Nếu chép, hash hoặc kiểm tra HTTP/HTTPS thất bại: khôi phục UPDATE từ backup, kiểm tra hash tệp đã khôi phục, xóa riêng các tệp ADD của giao dịch đang thất bại. Không phục hồi toàn bộ IIS và không đè các thư mục được bảo vệ.
6. Ghi `result.json`: `published`, `rolled_back`, hoặc `rollback_failed`. Lỗi trả mã thoát khác 0. Trạng thái `rolled_back` xác nhận khôi phục tệp; không bảo đảm sửa được sự cố mạng độc lập với website.

## Cài đặt và chạy

Sau khi được cho phép cài: sao lưu agent đang dùng, đối chiếu SHA bản mới, chép `Update-BanTin.ps1` vào `C:\BanTinAgent`, chạy Check dưới đúng tài khoản vận hành. Giữ nguyên quyền tài khoản, cấu hình site và các task hiện có trong lượt cài này.

```powershell
$script = 'C:\BanTinAgent\Update-BanTin.ps1'
$sha = '<full SHA đã xem Preview>'
& powershell.exe -NoProfile -File $script -Mode Check -Channel Preview -ReleaseTag "preview-$sha"
if ($LASTEXITCODE -ne 0) { throw 'Check chưa đạt; dừng cập nhật.' }
```

Kênh Preview dùng `Mode Publish -Channel Preview`. Kênh Production bắt buộc thêm `ApprovedCommit`, `ApprovalPhrase` và `ReleaseTag` cụ thể; thiếu câu duyệt hoặc full SHA sẽ bị từ chối trước khi tạo thư mục làm việc. Full SHA phải bằng `manifest.commit`, không chỉ khớp 12 ký tự của tag. Chỉ truyền câu duyệt sau khi người dùng thực sự duyệt phiên bản tương ứng. `Mode Check -Channel Production` là kiểm tra, không phải cho phép ghi Production.

Không bật tác vụ Production thăm dò rồi tự xuất bản release mới. Task Production cũ không có tham số duyệt sẽ bị từ chối. Workflow tạo release vẫn cần kiểm tra issue có `status: published` và SHA đã xem không thay đổi; thay nội dung hoặc trạng thái làm đổi SHA thì cần dựng lại Preview.

## Kiểm thử

```powershell
powershell.exe -NoProfile -NonInteractive -File deploy/Test-Update-BanTin.ps1
```

Bộ thử dùng thư mục TEMP riêng, thay duy nhất đường dẫn webroot trong bản sao thử nghiệm, và mô phỏng tải release/HTTP/curl. Không gọi Publish lên website thật. Kiểm tra Check, cập nhật thành công, rollback khi HTTP 500, lỗi tin cậy HTTPS, timeout, nội dung 200 sai hash, HTTPS công khai lỗi/sai nội dung; kiểm tra chặn Production thiếu duyệt hoặc sai full SHA. Xác minh tệp bảo vệ, tệp ngoài gói và snapshot vẫn nguyên sau rollback.

Chạy thêm `Mode Check` thật trên server với WorkRoot trong TEMP để xác minh tải release, hash và ba đường kiểm tra. Không lấy kiểm thử mô phỏng làm bằng chứng đã triển khai Production.

Tài liệu API: [Invoke-WebRequest cho Windows PowerShell 5.1](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1), [curl --resolve](https://curl.se/docs/manpage.html#--resolve).
