# Luồng tự động cho bản tin mới

## Một lần trên Windows Server

Hai Scheduled Task `BanTinAgent-Preview` và `BanTinAgent-Production` phải được cài và bật. Kiểm tra tại máy chủ bằng `Get-ScheduledTask -TaskName 'BanTinAgent*' -ErrorAction SilentlyContinue | Select TaskName,State`. Nếu chưa có task, quản trị viên kiểm tra script tại `C:\BanTinAgent\Update-BanTin.ps1` là phiên bản của repo, quyền ghi của tài khoản tác vụ và đường dẫn IIS, rồi chạy `Install-Task.ps1 -Channel Preview` và `Install-Task.ps1 -Channel Production` (nhập mật khẩu bằng hộp thoại tại máy chủ). Script tạo task ở trạng thái Disabled có chủ ý. Chạy `Update-BanTin.ps1 -Mode Check` cho từng kênh dưới đúng tài khoản tác vụ, kiểm tra backup và quyền, rồi bật bằng `Enable-ScheduledTask -TaskName BanTinAgent-Preview` và `Enable-ScheduledTask -TaskName BanTinAgent-Production`. Task tự thăm dò release mỗi 5 phút. Không bật production khi chưa xác nhận việc lấy release và khôi phục trên server.

## Mỗi số bản tin

1. Người biên tập gửi Word và ảnh. Agent biên tập tạo số báo ở `draft`, kiểm tra nội dung, dựng HTML và merge vào `main`. `build.yml` tự tạo release `preview-<40 SHA>` khi CI thành công. Task Preview tự cập nhật `C:\Web\bantin\ban-tin-moi`.
2. Người duyệt xem URL `/ban-tin-moi/so-XX-YYYY.html` và phản hồi. Mỗi sửa đổi được merge thành commit mới, nên Preview mới được tạo và cập nhật tự động. Ghi lại full SHA đã duyệt.
3. Khi người duyệt nói rõ duyệt xuất bản, agent chỉ đổi `status` của đúng tệp `content/issues/so-XX-YYYY.json` từ `draft` sang `published` trong một commit riêng, không sửa nội dung hay ảnh. Đây là tín hiệu phê duyệt có thể kiểm toán trong Git. Nếu sửa nội dung đồng thời, workflow từ chối và phải xem lại Preview.
4. `build.yml` kiểm tra và tạo Preview cho commit duyệt. Workflow `auto-publish-bantin.yml` đợi CI thành công, xác nhận commit chỉ đổi trạng thái, Preview trước và sau commit tồn tại, và `main` còn trùng SHA; sau đó tạo release Production `bantin-YYYY.N-<12 SHA>`. Agent Production tự cập nhật webroot. Không cần chạy workflow hoặc PowerShell cho từng số khi task đã bật.
5. Kiểm tra URL trang chủ và trang số báo; lưu SHA, tag, kết quả HTTP và backup. Nếu CI/release/task/SSL lỗi, dừng và báo đúng chặng, không nói đã xuất bản khi IIS chưa xác nhận.

Các release chỉ chứa tệp được phép. Agent giữ `web.config`, `admin/`, `oauth/`, `ban-tin-moi/` và các tệp ngoài gói, xác minh SHA-256, sao lưu trước khi thay và ghi nhật ký ở `C:\BanTinAgent\logs`. `Production` dùng release không phải prerelease; `Preview` chỉ dùng prerelease. Workflow thủ công `Publish approved BanTin` còn là phương án xử lý trường hợp đặc biệt, không dùng cho luồng số mới thông thường.

**Giới hạn:** ChatGPT/GitHub không có quyền điều khiển Windows Server trong phiên này. Việc bật task là cấu hình một lần do người có quyền trên IIS thực hiện. Không có bằng chứng task đã bật chỉ từ việc workflow tạo release; URL công khai và log máy chủ mới chứng minh triển khai hoàn tất.
