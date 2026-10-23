# Bàn giao bản tin số 38 năm 2026

## Trạng thái

ĐÃ XÁC NHẬN: đã chuyển đổi BT38.docx theo mẫu BT39_Template_Demo(1).html mới nhất được đính kèm trong cuộc trò chuyện. Có HTML tự chứa ảnh/biểu đồ/Anton và PDF A4 36 trang. Đã đối chiếu chính xác 154 khối có chữ hoặc biểu đồ, đủ 10 bài (3 trong nước, 6 nước ngoài, 1 chuyên sâu), 2 bảng và 5 biểu đồ Word. Giữ cả sáu URL nguồn, ô trống trong bảng, lỗi chính tả hoặc câu chưa rõ trong bản gốc; không tự biên tập nội dung. Bảng và biểu đồ giữ đúng vị trí tương đối; tiêu đề, đơn vị, nguồn được nhóm khi ngắt trang.

CHƯA KIỂM CHỨNG: chưa triển khai lên IIS; chưa kiểm tra 200/iframe trên máy chủ thật; chưa sửa index hoặc tự động đồng bộ máy chủ. Không có kết nối Remote trong phiên này. Bản dựng Chromium kiểm tra responsive chưa thực hiện được do môi trường không có trình duyệt và tải bổ sung thất bại; CSS mobile/iframe đã được chuẩn bị nhưng cần thử trên trình duyệt thực tế. PDF đã kiểm tra bố cục bằng ảnh render.

ĐỀ XUẤT: dùng nhãn 38/2026 dựa vào tên BT38.docx, các mốc nội dung và metadata tháng 10/2026. Word không có nhãn số/năm bản tin trên bìa để xác nhận độc lập. Cần người phụ trách xác nhận trước phát hành.

## Nội dung cần xử lý trước phát hành

| ID | Vị trí | Dữ kiện giữ nguyên | Việc cần xác nhận |
|---|---|---|---|
| F01 | Biểu đồ cuối, PDF trang 33; bảng 8 tháng trang 29 | Biểu đồ: 2025 = 5.357.243 USD; 2026 = 4.107.825 USD. Bảng: 2025 = 2.561.069 USD; 2026 = 4.130.967 USD. | Xác nhận bộ số liệu đúng và cung cấp Word chỉnh sửa hoặc cho phép sửa cụ thể. Chênh lệch 2025 = 2.796.174 USD; 2026 = -23.142 USD nếu lấy biểu đồ trừ bảng. |
| F02 | Đoạn mô tả 8 tháng, PDF trang 32 | Văn bản nói tăng 61,3%, từ 2,6 lên 4,1 triệu USD; chiều hướng biểu đồ gốc là giảm. | Xác nhận thống nhất biểu đồ, bảng và diễn giải. Không tự chọn nguồn thay thế. |
| F03 | Trang bìa | Word không có ảnh mặt hàng; hai khung minh họa ống đồng và ruy băng để chờ ảnh. Logo, tàu và QR lấy từ mẫu 39. | Cung cấp hai ảnh phù hợp có quyền sử dụng. Không dùng ảnh ván gỗ/xe điện của số 39 cho số 38. |
| F04 | Trang cuối | Word không có thông tin nhân sự. Chỉ giữ cơ quan và CIEW/liên hệ từ mẫu, không sao chép tên người chịu trách nhiệm của số 39. | Bổ sung nhân sự nếu kỳ này cần. |
| F05 | Bài ruy băng, đoạn “Thị trường … và xu hướng” | Có đoạn mở đầu nói về sợi polyester, kéo sợi, dệt kim và dệt thoi. | Rà soát sự phù hợp với mặt hàng ruy băng nhựa; bản chuyển đổi giữ nguyên. |
| F06 | Bảng 8 tháng, hàng Phi-líp-pin | Ô trị giá 8T/2025 để trống, tăng trưởng N/A. | Không quy ô trống thành 0. Chỉ bổ sung khi có dữ liệu gốc. |

Tỷ lệ tăng 61,3% được bảng hỗ trợ sau làm tròn; các phát hiện trên là đối chiếu nội bộ, không xác minh độc lập các vụ việc pháp lý hoặc số liệu thương mại trên Internet.

## Thiết kế và tài nguyên

- Bìa, mục lục ba nhóm, trang trong một cột, trang cuối trắng theo mẫu số 39; Times New Roman 14pt cho nội dung, Arial cho tiêu đề, Anton cho số, nguồn/tác giả 11pt. Header/footer PDF có trang hiện tại/tổng trang.
- Biểu đồ được kết xuất trực tiếp từ đối tượng Word bằng LibreOffice rồi nhúng SVG, không tự nhập lại dữ liệu. Dữ liệu cache và SHA-256 của từng chart có trong Kiem_tra_noi_dung.json.
- HTML tự chứa toàn bộ ảnh/SVG và Anton, không có đường dẫn tài nguyên cục bộ/tạm. Arial và Times New Roman trong HTML dùng font cài trên thiết bị; không phân phối font Microsoft. PDF nhúng font và được dựng trên máy có đúng Arial/Times New Roman.
- Có khung chờ ảnh trong bài thông báo miễn trừ ngắn. Những trang tiếp diễn có khoảng trống được để nguyên để không thêm thông tin không có nguồn.
- Mục lục HTML hiển thị số trang của PDF giao kèm, không phải số màn hình. Nếu thay nội dung/font cần dựng PDF và mục lục lại.
- In bằng trình duyệt có thể phân trang khác PDF WeasyPrint. Khi phát hành bản in nên dùng PDF giao kèm.
- Khung chờ ảnh là thành phần chế bản bổ sung, không phải nội dung gốc; bị loại khỏi phép đối chiếu văn bản gốc.

## Triển khai theo từng bước

Gói không sửa IIS, OAuth, firewall, chứng thư, web.config, admin hoặc số 39. Không chạy iisreset. Chưa đăng công khai số 38 vì F01/F02 chưa được xử lý.

1. Giải nén toàn bộ gói vào `C:\Installers\BT38_2026` trên máy chủ. Giữ nguyên file HTML/PDF và manifest.json cạnh Deploy-BT38.ps1.
2. PowerShell Administrator, kiểm tra gói và chép vào vùng staging ngoài webroot (không public):

```powershell
Set-Location C:\Installers\BT38_2026
Get-AuthenticodeSignature .\Deploy-BT38.ps1
Get-FileHash .\so-38-2026.html -Algorithm SHA256
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Deploy-BT38.ps1
```

Script tự so SHA-256 với manifest. Script tự tạo là unsigned; cần đọc nội dung trước khi chạy. ExecutionPolicy Bypass chỉ áp dụng tiến trình này, không thay policy hệ thống. Mặc định chỉ stage tại `C:\Apps\pvtm-ban-tin-staging\so-38-2026`, chưa phục vụ HTTP.

3. Sau khi đã chốt dữ liệu và ảnh, dựng lại gói. Chỉ khi người phụ trách đã duyệt đúng bản đang có mới chạy chế độ phát hành:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Deploy-BT38.ps1 -Publish -Reviewed
```

Lệnh có thể phát hành nguyên trạng bản còn mâu thuẫn nếu chủ động dùng -Reviewed; đây là xác nhận của người chạy, không tự chứng minh dữ liệu đã sửa. Bản hiện tại được bàn giao để xem xét, chưa nên chạy bước này.

4. Script chỉ sao lưu và cập nhật `C:\Web\bantin\so-38-2026.html` và `.pdf`. Không sửa trang chủ. Có deployment.json ở thư mục backup; ghi rõ file nào trước đó tồn tại và hash file đã triển khai. Script dừng nếu phát hiện thay đổi ngoài dự kiến khi triển khai. Nếu có lỗi giữa hai file, dùng rollback theo record để khôi phục.
5. Kiểm tra trên máy ngoài cơ quan, không dùng -k:

```powershell
curl.exe --noproxy "*" --head --max-time 30 "https://bantin.trav.gov.vn/so-38-2026.html"
curl.exe --noproxy "*" --head --max-time 30 "https://bantin.trav.gov.vn/so-38-2026.pdf"
```

Mong đợi 200. Kiểm tra ảnh, bảng, font, liên kết mục lục trên desktop/điện thoại; thử iframe trên website Cục. Nếu 404 kiểm tra đúng file và physical path; nếu bị chặn frame kiểm tra header X-Frame-Options/CSP, không gỡ bảo vệ toàn website.
6. Hoàn tác chỉ hai file của lần triển khai, dùng đường dẫn record được script in ra:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Rollback-BT38.ps1 -BackupDir "C:\Backups\BanTin\BT38_<timestamp>"
```

Rollback so hash file hiện tại trước khi ghi đè; nếu có chỉnh sửa mới, dừng để kiểm tra. Không restore toàn bộ IIS/firewall.

## GitHub và CMS

Đã kiểm tra repo pvtm-trav/pvtm-ban-tin có quyền push. Nhánh main tại thời điểm đọc: eaff81da69a2343786140b44553a280c724eca60. Thay đổi máy chủ trước đây (OAuth và xóa nhãn trang chủ) chưa có trong main khi kiểm tra. Không kéo bản repo cũ đè cấu hình máy chủ.

Bản số 38 được chuẩn bị trên nhánh review/so-38-2026, PR nháp, không merge/publish tự động vì F01/F02. Các file thêm nằm trong editions/so-38-2026 và imports/so-38-2026. Không sửa build.py, template chung, OAuth hoặc dữ liệu số 39.

Thư mục cms-content trong gói là dữ liệu JSON đã chuẩn bị để nhập CMS (10 bài + 1 số, status=draft); chưa nhập vào content đang hoạt động. Template chung trên repo cũ chưa đồng bộ với mẫu HTML mới nhất. Không nhập rồi build và coi đó là cùng một bản thiết kế đã kiểm tra. Cần thống nhất template/bộ dựng trước khi chọn CMS làm nguồn xuất bản chính; tránh chỉnh hai nguồn HTML và JSON song song.

## Iframe sau phát hành

Dùng iframe-so-38.html. Trỏ trực tiếp trang số 38, không trỏ trang chủ, không trỏ admin, dùng HTTPS. Trước khi file có trên máy chủ, URL này chưa được xác nhận hoạt động. Query phiên bản trong iframe chỉ giúp phân biệt cache, không thay bước upload.

## Lưu trạng thái

Hoàn tất chế bản và gói triển khai có kiểm tra. Chưa phát hành IIS, chưa chốt dữ liệu/ảnh, chưa tích hợp import CMS. Không có mật khẩu, Client secret, token hoặc khóa riêng trong gói. Tài liệu bàn giao này chỉ mô tả số 38, không thay bản sao lưu hạ tầng.

CHƯA KIỂM CHỨNG: script PowerShell đã rà soát nội dung nhưng chưa thực thi trên Windows Server trong phiên này. Cần chạy staging trước, xem kết quả rồi mới triển khai bản đã duyệt.
