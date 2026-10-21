# Bản tin PVTM và Cảnh báo sớm số 08 năm 2026

Trạng thái: **bản nháp để duyệt**, không phát hành lên trang chính. Nguồn: tệp Word `1232026_BT08_Draft.docx` do người phụ trách cung cấp ngày 21/10/2026. Mã số 08/2026 lấy từ tên tệp và yêu cầu trong cuộc trao đổi; ngày phát hành chưa được cung cấp. Bìa ghi `08.2026` và mục lục ghi ngày chưa xác nhận.

## Nội dung đã chuyển

- 8 bài theo đúng thứ tự Word: 1 tin trong nước, 6 tin nước ngoài, 1 bài viết chuyên đề. Bài viết được lưu với category kỹ thuật `THÔNG TIN XUẤT NHẬP KHẨU` để tương thích bộ dựng; nhãn hiển thị là `BÀI VIẾT` theo Word.
- 1 bảng 6 cột và 10 hàng dữ liệu. Bốn biểu đồ được dựng SVG từ dữ liệu cache trong `word/charts/chart1.xml` đến `chart4.xml`; tệp XML gốc và `chart-data.json` được giữ trong assets để đối chiếu. Không thay ô trống bằng 0.
- Các đoạn có `w:ins` trong Word đã được lấy theo phần chữ hiện hành, không lấy chữ bị xóa. Toàn bộ đoạn văn, đầu mục, dòng nguồn và từng ô bảng đã đối chiếu theo thứ tự với Word sau khi dựng HTML.
- Hai tin nổi bật trên bìa: tin Hoa Kỳ về thép cốt bê tông từ Việt Nam và tin In-đô-nê-xi-a đề nghị WTO về dầu cọ. Nguồn Word không có ảnh bìa/ảnh tin nổi bật; bản nháp hiển thị ba ô chờ ảnh, không tự gán ảnh cho bài.
- Mẫu thiết kế dựa trên số 21/2026, vốn được chỉnh theo chuẩn số 39/2026. Mục lục web hiển thị trang 3, 5, 7, 8, 10, 12, 14, 16; bản in dùng `target-counter` để lấy trang thực tế.

## Cần người phụ trách nội dung xem trước khi phát hành

1. Đoạn tổng kết ở phần “Tình hình nhập khẩu máy giặt dân dụng cỡ lớn vào Hoa Kỳ từ Việt Nam” nói Việt Nam “tiếp tục mở rộng đầu tư sản xuất” và “nhu cầu ... ngày càng gia tăng”, trong khi số xuất khẩu 2023–2025 trong chính Word giảm từ 281.239.740 xuống 246.605.906 rồi 222.482.441 USD. Hai ý có thể cùng đúng nếu nói về đầu tư và nhu cầu, nhưng không nên suy ra kim ngạch Việt Nam tăng; cần tác giả rà soát cách diễn đạt. Các giá trị giữ nguyên.
2. Biểu đồ tổng nhập khẩu Hoa Kỳ ghi 1.360.723.516 USD (2023), 1.445.190.159 USD (2024), 1.287.672.222 USD (2025). Bảng năm 2024–2025 ghi phần mười nguồn chính và nguồn khác; không đồng nhất mọi tổng làm tròn trong lời văn với dữ liệu thô. Không sửa số liệu nghiệp vụ.
3. Cần cung cấp/duyệt ảnh bìa và hai ảnh tin nổi bật, đồng thời xác nhận ngày phát hành nếu muốn ghi ngày.
4. Bản Word chứa một số chữ được thêm bằng tracked changes. HTML lấy nội dung hiện hiển thị sau sửa đổi; người duyệt nên đối chiếu ý cuối cùng với tác giả.

## Kiểm tra kỹ thuật

- `PYTHONPATH=../deps python build.py --include-drafts`: dựng 3 số, số 08 có nhãn `BẢN NHÁP`; `python build.py` không đưa số 08 vào danh mục production.
- Render WeasyPrint 30 trang A4 bằng phông thay thế của môi trường: 8 anchor và số trang mục lục khớp. Bảng 10 hàng nằm trọn một trang, biểu đồ và dòng nguồn được nhóm. Bản PDF là hiện vật kiểm tra, chưa phát hành.
- Giao diện trên IIS và các trình duyệt của người phụ trách chỉ có thể xác nhận sau khi agent Preview tải release mới. Kênh Production chỉ dùng sau một lần duyệt rõ ràng cho đúng commit.
