# Bản tin: xem thử → duyệt → xuất bản

**Chưa kích hoạt trên IIS.** Mã này cần được rà PR, chạy CI Windows PowerShell 5.1, và thử trên máy chủ trước khi bật hai task. Bản snapshot từ 21/10/2026 ghi số 21 đã được duyệt về thiết kế, nhưng chưa xác nhận lên website chính.

| Kênh | Release | Đích IIS | Điều kiện |
|---|---|---|---|
| Preview | `preview-<commit SHA>`, prerelease | `C:\Web\bantin\ban-tin-moi` | Push lên `main` → tự build cả draft và published |
| Production | `bantin-<năm>.<số>-<12 ký tự SHA>` | `C:\Web\bantin` | Người duyệt chỉ định đúng issue và **toàn bộ SHA đã xem** trong workflow Publish approved BanTin |

Gói production chỉ dựng issue có `status: published`. Cả hai gói đều loại `admin/`, `web.config`, `/ban-tin-moi/` và `/oauth/`; agent cũng chặn các đường dẫn này. Tệp không thuộc gói được giữ lại. Vì vậy không dùng agent để dọn tệp cũ. Mỗi release có ZIP, SHA-256 từng tệp, commit và channel trong `release.json`. SHA-256 xác nhận tính toàn vẹn tải về, không thay thế quyền phát hành GitHub.

## Thiết lập một lần trên IIS

1. Đối chiếu read-only Physical path thực tế, ACL, trạng thái task cũ `BanTinAgent-Publish` và sao lưu webroot. Dừng task cũ trước khi cài bản mới; nó nhắm sai mục đích của kênh production.
2. Tải `Update-BanTin.ps1`, `Install-Task.ps1` từ commit đã rà vào `C:\BanTinAgent`. Khóa quyền sửa mã cho quản trị viên. Tạo tài khoản tác vụ riêng có Modify trên `C:\BanTinAgent\downloads`, `backups`, `logs`, `agent.lock` và đúng thư mục đích. Tài khoản production cần Modify vào webroot nhưng không cần quyền Administrator; script không chạm các thư mục được bảo vệ. Nên tách hai tài khoản Windows để giới hạn quyền. Cả hai có quyền Log on as a batch job; IIS App Pool chỉ đọc.
3. Tạo hai task **Disabled** bằng `Install-Task.ps1 -Channel Preview` và `-Channel Production` (chạy PowerShell nâng quyền, nhập credential tại máy chủ). Trước khi bật task, chạy `Update-BanTin.ps1 -Mode Check -Channel Preview` và `-Mode Check -Channel Production` dưới đúng tài khoản task. Nếu production chưa có release schema 2, Check sẽ báo lỗi; đây là chặn có chủ đích.
4. Sau khi có preview release mới, chạy thủ công `-Mode Publish -Channel Preview`, kiểm tra URL `/ban-tin-moi/` và ảnh số 21 qua HTTP. Khi đã thử rollback, bật `BanTinAgent-Preview`. Không bật task production lúc này.
5. Người duyệt kiểm tra trang preview và ghi lại full SHA tương ứng với release `preview-<SHA>`. Chạy workflow **Publish approved BanTin** trên `main`, nhập `so-21-2026`, SHA đó và tick approved. Workflow từ chối nếu `main` thay đổi kể từ lúc xem. Nó xuất release chính thức trực tiếp, không đòi tag hay bấm Publish release.
6. Chạy `-Mode Check -Channel Production`, xem danh sách ADD/UPDATE, kiểm tra backup và URL đích, rồi `-Mode Publish -Channel Production`. Xác minh trang `/` và `/so-21-2026.html` công khai trước khi bật `BanTinAgent-Production`. Lần sau release được task lấy tự động theo chu kỳ 5 phút.

Ví dụ lệnh kiểm tra (đường dẫn đã ghi trong bàn giao; xác minh trước khi chạy):

```powershell
& 'C:\BanTinAgent\Update-BanTin.ps1' -Mode Check -Channel Preview
& 'C:\BanTinAgent\Update-BanTin.ps1' -Mode Check -Channel Production
Get-ScheduledTask -TaskName 'BanTinAgent*' | Select-Object TaskName,State
```

**Giới hạn hiện tại:** bước duyệt là một lần chạy workflow với issue ID và SHA, chưa có nút duyệt trong CMS. Agent không tự chứng minh HTML/ảnh trông đúng; HTTP check chỉ báo status. Không có kết nối điều khiển IIS từ môi trường này; phải xác minh thực tế trên máy chủ. Preview không tự thay thế nội dung production. ZIP không chứa PDF nếu build chưa tạo PDF.

## Khôi phục

Tắt task tương ứng, đọc `C:\BanTinAgent\backups\<lần cập nhật>\journal.json`, khôi phục UPDATE từ bản sao lưu và xóa riêng ADD của lần đó sau khi kiểm tra không bị bản sau dùng chung. Giữ nguyên `web.config` và các thư mục hệ thống. Sửa nguồn, tạo commit/release mới trước khi bật lại task để không tự áp lại bản lỗi. Log nằm trong `C:\BanTinAgent\logs`.
