# Bộ cập nhật Bản tin v1

Chỉ ghi `C:\Web\bantin\ban-tin-moi`. Không sửa website gốc, không xóa file cũ, không triển khai web.config. Tác vụ không thực hiện nhập Word/MD; phần agent biên tập sẽ triển khai sau.

## Phạm vi đã kiểm tra và giới hạn

Đây là bộ mã chuẩn bị triển khai, chưa chạy trên máy chủ thật. Môi trường phát triển không có PowerShell; workflow cung cấp bước kiểm tra cú pháp bằng Windows PowerShell 5.1, cần xem kết quả khi chạy trên GitHub. Chép từng file không bảo đảm cả site thay đổi đồng thời; index được chép cuối và có rollback khi lỗi được bắt. Nếu mất điện/tiến trình bị dừng, dùng journal và bản sao lưu để khôi phục thủ công. Không xóa downloads/backups tự động trong v1; quản trị viên theo dõi dung lượng. SHA-256 kiểm tra tính toàn vẹn; quyền phát hành GitHub là ranh giới tin cậy, không phải chữ ký độc lập.

## Chuẩn bị một lần

1. Giữ nguyên `C:\Web\bantin`. Tạo `C:\BanTinAgent` và `C:\Web\bantin\ban-tin-moi`.
2. Tải Update-BanTin.ps1 và Install-Task.ps1 từ đúng commit đã kiểm tra vào C:\BanTinAgent. Đọc mã trước khi chạy. Không đặt script/bản sao lưu trong thư mục web.
3. Tạo tài khoản Windows riêng. Cấp Read & Execute lên script; Modify lên downloads, backups, logs và ban-tin-moi; quyền Log on as a batch job. IIS được Read & Execute ban-tin-moi. Không cấp Modify website gốc. Khóa quyền sửa script cho quản trị viên. File agent.lock ở WorkRoot cần được tạo trước và cấp quyền ghi cho tài khoản tác vụ; tài khoản cũng cần quyền tạo thư mục làm việc trong lần thiết lập đầu hoặc quản trị viên tạo sẵn.
4. Chạy Check bằng chính tài khoản tác vụ. Chưa có release hợp lệ thì lỗi 404 là dự kiến, chưa được coi là thử triển khai thành công.

```powershell
powershell.exe -NoProfile -File C:\BanTinAgent\Update-BanTin.ps1 -Mode Check
```

Check chỉ tải/xác minh và hiển thị ADD/UPDATE; không ghi website. Publish kiểm tra lại gói trước khi ghi:

```powershell
powershell.exe -NoProfile -File C:\BanTinAgent\Update-BanTin.ps1 -Mode Publish
```

Chỉ thử Publish sau khi đã kiểm tra danh sách Check. Nếu execution policy chặn script, thực hiện quy trình ký/cho phép script của đơn vị; không tắt chính sách toàn máy.

## Tạo gói đã duyệt

Sau khi PR được hợp nhất vào main: Actions → Prepare approved BanTin release → Run workflow; nhập tag duy nhất `bantin-2026.40.1`, đánh dấu đã duyệt. Chương trình chỉ đóng gói số có status published; không dùng --include-drafts. Hiện số 39 trong kho là draft nên phải duyệt nội dung và đổi trạng thái trước khi tạo gói. Không tự đổi trạng thái số 39 trong thay đổi này.

Workflow tạo **Draft Release** chứa bantin-site.zip và release.json. Kiểm tra gói rồi Publish release (không chọn prerelease). Chỉ release chính thức với tag bantin-* được tác vụ nhận. Không tạo release khác loại trong cùng kho: endpoint latest dùng chung cho toàn repo. Cần kiểm tra thêm tải GitHub Release assets từ máy chủ; thành công tải raw README chưa chứng minh tải được release-assets qua redirect.

Gói HTML dùng đường dẫn tương đối của build.py, chạy trong /ban-tin-moi/. Trang Decap có thể có URL tuyệt đối /assets khi biên tập/xem trước; xác thực và cấu hình CMS thư mục con chưa hoàn tất. Không coi trang admin là đã vận hành. Workflow này chưa xuất PDF; cần máy dựng có font hợp lệ và kiểm tra PDF trước khi bổ sung vào gói.

## Scheduled Task mỗi 5 phút

Chạy Install-Task.ps1 trong PowerShell nâng quyền; nhập thông tin tài khoản tại hộp thoại cục bộ. Script tạo task **Disabled**. Sau khi Check và Publish thủ công thành công bằng đúng tài khoản:

```powershell
Enable-ScheduledTask -TaskName BanTinAgent-Publish
Get-ScheduledTaskInfo -TaskName BanTinAgent-Publish
```

Task dùng RunLevel Limited, không chạy chồng. Dừng bằng Disable-ScheduledTask. Không cần restart IIS. Log: C:\BanTinAgent\logs. Mỗi lần vẫn xác minh nội dung thật; nếu trùng hash thì không ghi website. HTTP kiểm tra tính sẵn có riêng, chưa so sánh nội dung trả về qua HTTP. Lỗi HTTP được ghi log để xem xét, không tự rollback chỉ vì lỗi mạng.

## Khôi phục

Tắt task trước. Trong backups/<lần cập nhật>/journal.json: UPDATE có bản cũ theo cùng đường dẫn; ADD là file mới tạo. Sao chép bản cũ của UPDATE về ban-tin-moi; chỉ xóa ADD của lần đó nếu chắc chắn chưa bị bản phát hành sau sửa. Không phục hồi vào C:\Web\bantin gốc. Kiểm tra site rồi mới bật lại task. Nếu bản phát hành lỗi đã công khai, sửa và tạo tag mới trước khi bật task, tránh tác vụ áp lại bản lỗi.
