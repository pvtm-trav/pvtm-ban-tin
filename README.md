# Quản trị Bản tin PVTM & Cảnh báo sớm

Khung quản trị Decap CMS cho kho `pvtm-trav/pvtm-ban-tin`.

## Trạng thái

Đây là bản khởi tạo **chỉ gồm mã nguồn, cấu hình và ảnh giữ chỗ**. Chưa đưa bản thảo số 39, ảnh tàu, logo, ảnh sản phẩm hoặc biểu đồ của ấn phẩm lên nhánh này. Các tệp đó được giữ trong gói bàn giao riêng; việc đưa lên kho Public cần được chủ dữ liệu xác nhận.

Có mẫu bìa, mục lục ba chuyên mục, trang bài một cột, trang cuối; công cụ dựng HTML/PDF; biểu mẫu nhập bài và số bản tin. Chưa triển khai hosting hoặc cấu hình OAuth, vì vậy chưa có trang quản trị trực tuyến đã đăng nhập được.

Quy chuẩn: Arial cho tiêu đề, Times New Roman 14pt cho nội dung, dòng tác giả/nguồn 11pt, Anton cho số bản tin; tên cơ quan bìa 16pt, liên hệ bìa 13pt. Ảnh và biểu đồ căn giữa, rộng khoảng 75% A4. Không có thanh điều hướng hoặc nút in trên bản tin.

## Chạy tại máy tính

Cài Python 3.12, Git; mở Terminal trong thư mục kho:

```sh
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python build.py
python -m http.server 8000 --directory public
```

Mở `http://localhost:8000`. Khi chưa có số phát hành, trang chủ hiển thị thông báo chưa có bản tin. Thư mục `public/` được tạo lại khi dựng, không sửa trực tiếp và không đưa vào Git.

## Bật trang quản trị

1. Liên kết kho này với hosting, ví dụ Netlify.
2. Build command: `pip install -r requirements.txt && python build.py`.
3. Publish directory: `public`.
4. Cấu hình xác thực GitHub theo tài liệu chính thức: https://decapcms.org/docs/github-backend/ . Không đặt Client Secret trong mã nguồn hoặc trong `config.yml`.
5. Khi có tên miền và OAuth hoạt động, mở `https://TEN-SITE/admin/` để đăng nhập.

`admin/config.yml` đã trỏ đúng kho và nhánh `main`. Nếu dùng máy chủ OAuth riêng, cần cấu hình `base_url` và `auth_endpoint` tương ứng; chưa giả định callback khi chưa có hosting.

Decap CMS là mã nguồn mở. Hosting và xác thực có hạn mức/chi phí riêng theo dịch vụ.

## Tạo một số bản tin

1. Vào **Bài viết**, tạo mã bài, nhập tiêu đề, chọn chuyên mục và soạn nội dung. Bộ soạn thảo có chế độ trực quan và mã HTML. Với bảng/biểu đồ, kiểm tra lại bản dựng trước phát hành.
2. Vào **Bản tin**, nhập mã ví dụ `so-40-2026`, số/năm, ảnh chính, hai headline và ảnh minh họa.
3. Chọn các bài theo thứ tự: tin trong nước → tin nước ngoài → thông tin xuất nhập khẩu.
4. Dùng trạng thái **Bản nháp** khi biên tập. CMS dùng quy trình editorial workflow; thao tác Publish hợp nhất dữ liệu vào main, còn trường `status: published` quyết định số đó có hiện trên trang đọc hay không.
5. Dựng và xem trước; chỉ phát hành sau khi kiểm tra nội dung, ảnh và PDF.

Ảnh chính mới thông thường dùng `hero_top_mm: 0`. Vị trí có thể điều chỉnh sau khi xem trước.

`python build.py --include-drafts` dựng cả bản nháp để xem nội bộ. Bản dựng mặc định chỉ đưa số có trạng thái `published` lên trang đọc. Khi chưa tính PDF, số trang mục lục trên HTML dùng dấu `—` để tránh hiển thị số trang cũ.

## Xuất PDF A4

```sh
pip install -r requirements-pdf.txt
python build.py --include-drafts --pdf
```

Máy dựng cần Pango/Fontconfig và Arial, Times New Roman được cài hợp lệ. Nếu thiếu hai font, chương trình dừng thay vì thay font ngầm. Font Microsoft không được kèm trong kho; Anton có giấy phép OFL đi kèm.

Hướng dẫn thư viện hệ thống: https://doc.courtbouillon.org/weasyprint/stable/first_steps.html . Có thể chạy qua WSL/Linux đã cài đủ thư viện và font. Header/footer và số trang dựa vào WeasyPrint; chức năng in trình duyệt có thể khác.

Workflow GitHub hiện chỉ dựng HTML và lưu artifact kiểm tra, chưa tự xuất PDF vì cần chuẩn bị máy dựng có font hợp lệ.

## Cấu trúc

| Thư mục/tệp | Vai trò |
|---|---|
| `admin/` | Decap CMS, cấu hình và bộ soạn thảo |
| `content/issues/` | Dữ liệu từng số, định dạng JSON |
| `content/articles/` | Bài viết, định dạng JSON |
| `assets/media/` | Thư viện ảnh; hiện chỉ có ảnh giữ chỗ |
| `assets/fonts/` | Anton và giấy phép OFL |
| `templates/newsletter.html.j2` | Mẫu thiết kế |
| `build.py` | Công cụ dựng HTML/PDF |
| `.github/workflows/build.yml` | Kiểm tra và đóng gói HTML |

Bộ soạn thảo đã kiểm tra cú pháp JavaScript; cấu hình đã kiểm tra YAML; bước dựng mẫu đã kiểm tra tại máy chuẩn bị. Cần kiểm thử đầy đủ đăng nhập, lưu bài, tải ảnh và chỉnh bảng trên trình duyệt sau khi thiết lập hosting/OAuth. Chưa hỗ trợ nhập Word tự động.
