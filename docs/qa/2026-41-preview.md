# Bản tin 41/2026 — ghi chú duyệt bản xem thử

Nguồn: 29102026_BT41.docx. Ngày phát hành chưa được xác nhận, không lấy ngày từ tên file để điền bìa. Trạng thái: draft. Chưa được phép xuất bản production.

## Chế bản
- Mẫu số 39, kế thừa các chỉnh sửa đầu/cuối trang từ mẫu số 40 hiện có trong main.
- 10 bài: 3 tin trong nước, 6 tin nước ngoài, 1 bài Thông tin xuất nhập khẩu.
- 2 bảng giữ nguyên ô dữ liệu; 5 biểu đồ lấy số liệu cache XML gốc trong Word; lưu XML và chart-data.json để đối chiếu.
- Ảnh bìa cảng biển; headline 1 thép cán nguội; headline 2 bút chì. 9 bài tin đều có ảnh minh họa, bài nghiên cứu có thêm ảnh bút chì.
- Nguồn bảng/biểu đồ căn giữa; nguồn bài căn phải.
- Bản HTML dùng Arial/Times New Roman 14pt, Anton cho số bản tin. Bản PDF nội bộ kiểm tra bố cục dùng font thay thế có sẵn trên máy dựng; không phải PDF phát hành. Số trang mục lục theo bản dựng kiểm tra, có thể thay đổi khi in từ trình duyệt/font khác.

## Nội dung cần người phụ trách xem lại (giữ nguyên Word)
1. Bài Nhật Bản: nêu hiệu lực từ 31/10/2024 đến 30/10/2031 nhưng khởi xướng tháng 5/2025; cần kiểm tra năm hiệu lực.
2. Bài Nhật Bản: câu “06 công ty” ở Đài Loan chỉ liệt kê 4 tên.
3. Bài bút chì/Mê-hi-cô: hai đoạn dùng “EU” ở phần các nguồn khác năm 2024 và thị phần Việt Nam 8 tháng 2026; cần xác nhận có phải Mê-hi-cô.
4. Bài I-xra-en: câu so sánh mô hình nhà kính với “mô hình trồng cần sa này” chưa rõ đối tượng so sánh.
5. Bài Hoa Kỳ/OCTG có đoạn cuối chuyển sang quyết định của Ca-na-đa; giữ nguyên nhưng cần xem có tách thành tin riêng không.
6. Chưa bổ sung nguồn/tác giả cho những bài Word không ghi nguồn/tác giả.

## Ảnh
Ảnh tải từ các trang tìm được theo chủ đề, lưu tại assets/issues/so-41-2026 và có chú thích minh họa. Ảnh cần sa minh họa cơ sở ở Úc, không mô tả là doanh nghiệp Ca-na-đa trong vụ việc. Xem image-sources.json để đối chiếu URL từng ảnh. Quyền tái sử dụng ảnh chưa được xác nhận; chưa coi việc có nguồn là giấy phép phát hành.

## Phạm vi triển khai
Chỉ cập nhật bản xem thử /ban-tin-moi/ sau backup. Không thay đổi trang chính, IIS, SSL, DNS, Firewall hoặc web.config. Chỉ xuất bản chính thức khi nhận DUYỆT XUẤT BẢN.
