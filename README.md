# Bản tin Phòng vệ thương mại & Cảnh báo sớm

Kho đích: **pvtm-trav/pvtm-ban-tin**, nhánh **main**.

Bộ khởi tạo được tách từ bản số 39 đã tinh chỉnh: không có thanh điều hướng/nút in; tên cơ quan Arial 16pt; hai headline Times New Roman; liên hệ bìa 13pt; nội dung Times New Roman 14pt; dòng tác giả/nguồn 11pt; số bản tin Anton. Ba nhãn mục lục trắng trên nền đỏ, trang trong một cột và trang cuối nền trắng. Hai bảng, năm biểu đồ và nguyên văn mười bài được giữ lại; sáu URL nguồn đã bỏ theo yêu cầu trước đó.

## Trạng thái hiện tại

- Có mẫu HTML dùng chung, dữ liệu số 39, bộ ảnh/biểu đồ, cấu hình Decap và chương trình dựng HTML/PDF.
- Số 39 đang là **draft**. Bản dựng mặc định không đưa bản nháp lên trang đọc công khai.
- Chưa cấu hình dịch vụ xác thực GitHub; chưa có trang quản trị trực tuyến hoạt động.
- Chưa triển khai hosting. Tệp `netlify.toml` là cấu hình dự kiến, không phải xác nhận đã triển khai.
- Bộ soạn thảo tùy chỉnh có chế độ trực quan và mã HTML. Cần kiểm thử đăng nhập, lưu bản nháp, tải ảnh và chỉnh bảng trên trình duyệt khi kết nối hosting. Chưa hỗ trợ nhập Word tự động.
- Bản xem trước Decap là phục vụ nhập liệu; bản HTML/PDF do `build.py` tạo mới là bản kiểm tra dàn trang.

## Bước 1 — Kết nối và quyền truy cập

Kết nối GitHub đã được thiết lập bằng tài khoản sở hữu kho `pvtm-trav`. Dùng kết nối này khi cập nhật mã và nội dung. Không đặt token, Client Secret hoặc mật khẩu trong mã nguồn.

Kho đang Public. Nội dung bản thảo và tài sản được đưa vào kho có thể được người khác đọc và tải xuống. Chủ dữ liệu đã xác nhận cho phép đưa bản số 39 cùng logo, hình ảnh và biểu đồ lên kho này.

## Bước 2 — Hợp nhất bộ khởi tạo

Bộ mã được đưa lên nhánh `setup/ban-tin-cms`, PR số 1. Kiểm tra kết quả GitHub Actions và thay đổi trong PR, sau đó hợp nhất vào `main` để làm nguồn triển khai hosting.

Không đưa thư mục `public/`, môi trường `.venv/`, mật khẩu hay khóa xác thực vào Git. `public/` được dựng tự động.

## Bước 3 — Chạy kiểm tra tại máy tính

Cần Python 3.12 và Git. Trong Terminal tại thư mục kho:

```sh
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python build.py --include-drafts
python -m http.server 8000 --directory public
```

Mở `http://localhost:8000` để xem bản tin. Lệnh có `--include-drafts` chỉ dùng cho xem trước nội bộ. Lệnh `python build.py` chỉ xuất những số có `status: published`.

Khi chưa xuất PDF, số trang của mục lục trên HTML hiện dấu `—` để tránh hiển thị số trang chưa được tính lại. Bước PDF sẽ tính lại số trang mục lục.

## Bước 4 — Kết nối Decap CMS

Cấu hình `admin/config.yml` đã dùng backend GitHub, kho `pvtm-trav/pvtm-ban-tin`, nhánh `main` và quy trình bản nháp/duyệt.

1. Tạo site trên dịch vụ hosting hỗ trợ xuất bản thư mục tĩnh, ví dụ Netlify, rồi liên kết đúng kho.
2. Dùng Build command `pip install -r requirements.txt && python build.py`; Publish directory `public`.
3. Cấu hình nhà cung cấp OAuth GitHub theo tài liệu chính thức; callback phụ thuộc dịch vụ xác thực được chọn. Chưa có URL hosting thì chưa điền callback theo phỏng đoán.
4. Với backend GitHub mặc định của Decap, cần hoàn thành thiết lập GitHub authentication của Netlify. Nếu dùng máy chủ xác thực khác, thêm `base_url` và `auth_endpoint` chính xác vào backend.
5. Sau khi kết nối OAuth xong, mở `https://TEN-SITE/admin/` và thử đăng nhập.

Tham khảo:
- https://decapcms.org/docs/github-backend/
- https://decapcms.org/docs/authentication-backends/
- https://decapcms.org/docs/editorial-workflows/

CMS mã nguồn mở; hosting/xác thực có hạn mức hoặc chi phí riêng tùy dịch vụ, không mặc định miễn phí toàn bộ.

## Bước 5 — Xuất PDF A4

Cài thư viện:

```sh
pip install -r requirements-pdf.txt
python build.py --include-drafts --pdf
```

WeasyPrint còn cần thư viện hệ thống Pango/Fontconfig tùy hệ điều hành. Máy dựng PDF phải có **Arial** và **Times New Roman** được cài hợp lệ; chương trình dừng nếu thiếu để tránh tự thay font làm sai dàn trang. Font Anton được kèm theo giấy phép OFL. Không kèm bản sao font Microsoft trong gói này.

Hướng dẫn hệ điều hành: https://doc.courtbouillon.org/weasyprint/stable/first_steps.html

Có thể dùng WSL/Linux đã cài đầy đủ font/thư viện để chạy PDF. HTML chỉ để xem trên trình duyệt không cần Pango. Số trang/header/footer dùng CSS Paged Media của WeasyPrint; chức năng in của các trình duyệt có thể khác.

Workflow GitHub đi kèm chỉ kiểm tra/dựng HTML và lưu artifact xem trước; chưa tự xuất PDF để tránh tự thay font. Muốn tự động hóa PDF chính xác cần cấu hình máy dựng có font hợp lệ.

## Biên tập mỗi kỳ

1. Trong **Bài viết**, tạo bài mới, nhập mã ví dụ `2026-40-01`, tiêu đề, chuyên mục và nội dung. Với bài có bảng/biểu đồ, kiểm tra HTML/PDF sau khi lưu.
2. Trong **Bản tin**, tạo mã `so-40-2026`, nhập số/năm, ảnh chính và hai headline.
3. Chọn các bài theo thứ tự: tin trong nước → tin nước ngoài → thông tin xuất nhập khẩu. Các mục lục tự lấy tiêu đề bài.
4. Lưu bản nháp, xem trước và kiểm tra. Chỉ đặt trạng thái **Phát hành trên trang đọc** sau khi duyệt, rồi thực hiện bước xuất bản của Decap. Trạng thái `published` trong dữ liệu và thao tác Publish của Decap là hai bước khác nhau: thao tác Publish đưa dữ liệu vào nhánh main; trường trạng thái quyết định có hiển thị trên trang đọc.
5. Dựng PDF để có số trang mục lục chính xác, kiểm tra rồi phát hành.

Ảnh tàu số 39 đang được cắt từ ảnh bìa mẫu, vì vậy `hero_top_mm = -76.3`. Khi thay ảnh tàu độc lập mới, dùng `0` và kiểm tra vùng cắt.

## Cấu trúc

| Đường dẫn | Vai trò |
|---|---|
| `admin/` | Trang quản trị Decap và bộ soạn thảo |
| `content/issues/` | Dữ liệu mỗi số bản tin |
| `content/articles/` | Các bài viết |
| `templates/newsletter.html.j2` | Mẫu thiết kế cố định |
| `assets/media/` | Logo, ảnh, QR, bảng biểu dạng ảnh/SVG |
| `assets/fonts/` | Anton và giấy phép |
| `validation/` | Bản đối chiếu nội dung số 39 |
| `build.py` | Dựng HTML/PDF và tính mục lục |
| `.github/workflows/build.yml` | Kiểm tra trên GitHub Actions |

Thông tin nhân sự trang cuối hiện giữ theo mẫu đã cung cấp, cần xác nhận trước phát hành chính thức. Ảnh bìa minh họa sản phẩm lấy từ https://www.woodsheets.com/mdf-sheet-cut-to-size/ và https://www.marshell.net/GolfCart/1364.html cho bản demo; trước phát hành dùng ảnh đơn vị có quyền sử dụng hoặc đã được cho phép. Ảnh tàu, logo và QR giữ theo tài liệu người dùng cung cấp.
