# Bản tin Phòng vệ thương mại và Cảnh báo sớm số 21 năm 2026

Trạng thái: BẢN NHÁP để rà soát, chưa sẵn sàng phát hành công khai.
Ngày phát hành: CHƯA XÁC NHẬN. Không suy đoán từ tên tệp Word.

## Mở bản tin

Giải nén toàn bộ gói và mở index.html trong Chrome hoặc Edge. Giữ styles.css và assets/ cùng vị trí tương đối. Không có PDF/ePaper phát hành trong gói này.

## Nội dung và mẫu

Nguồn: 110626_BT021_Draft.docx do người dùng cung cấp. Số 21 và năm 2026 do người dùng xác nhận trực tiếp.
Mẫu: BT39_HTML_CSS.zip. Bảo toàn thiết kế bìa, trang cuối, màu sắc, phông và các quy tắc ghi đè cuối CSS. Không sửa mẫu số 39.
Có 8 bài: 1 tin trong nước, 6 tin nước ngoài và 1 bài chuyên đề; 2 bảng, 5 biểu đồ. Giữ thứ tự và chuyên mục BÀI VIẾT theo Word.
Hai tin bìa được chọn nguyên tiêu đề: tin tiếp nhận hồ sơ thanh thép dự ứng lực và tin EU bảo vệ thị trường thép.

## Cần bổ sung và xác nhận trước phát hành

- Ảnh chính bìa; ảnh tin thanh thép dự ứng lực; ảnh tin EU bảo vệ thị trường thép. Word không có ảnh minh họa. Các ô chờ là phần tử HTML, không phải liên kết ảnh hỏng. Không tái sử dụng ảnh nội dung số 39.
- Ngày phát hành.
- Bài In-đô-nê-xi-a, đoạn bắt đầu “Theo số liệu của KADI”: vừa ghi tổng nhập khẩu từ Trung Quốc 117.036 tấn, vừa ghi nhập khẩu từ Trung Quốc 59.378 tấn. Giữ nguyên, cần xác nhận phạm vi của số tổng.
- Bài chuyên đề EU, đoạn bắt đầu “Năm 2024, Hàn Quốc”: Ấn Độ và Việt Nam đều được ghi xếp thứ tám; bảng thể hiện Việt Nam thấp hơn Ấn Độ. Đoạn về Việt Nam năm 2024 tiếp tục ghi xếp thứ tám. Giữ nguyên, không tự sửa.
- Các bản tin được chuyển nguyên văn, chưa xác minh nghiệp vụ với nguồn bên ngoài.

## Bảng và biểu đồ

Hai bảng được chuyển đầy đủ từng ô, không quy ô trống thành 0. Năm biểu đồ dựng lại thành SVG từ c:cat/c:val trong chart1.xml đến chart5.xml của Word. Không có workbook Excel nhúng. Lưu chart-data.json và năm tệp XML gốc trong assets/ để đối chiếu. Biểu đồ tròn hiển thị tỷ lệ phần trăm với hai chữ số thập phân; biểu đồ cột hiển thị USD với hai chữ số thập phân. Dữ liệu gốc giữ nguyên độ chính xác trong JSON/XML.

## CSS riêng

CSS được sao riêng cho số 21. Cỡ chữ bảng 10pt để đọc đủ sáu cột; bảng có thanh cuộn trên màn hình nhỏ. Tiêu đề, đơn vị, hình/bảng và nguồn được nhóm để tránh ngắt trang rời. Chú thích nguồn căn giữa. Ô chờ ảnh giữ hình học khung ảnh mẫu. Không tăng chữ hoặc giãn dòng để lấp trang.

## Cập nhật repository

Kho đã xác nhận bằng README hiện hành: pvtm-trav/pvtm-ban-tin, nhánh main. Số 21 nằm ở content/issues/so-21-2026.json và 8 bài content/articles/2026-21-*.json, trạng thái draft. Mẫu riêng templates/issues/so-21-2026.html.j2 cùng tài nguyên assets/issues/so-21-2026/. build.py chọn mẫu riêng theo mã số khi có, giữ mẫu dùng chung và các số cũ.
Dựng xem trước: python build.py --include-drafts. Danh mục xem trước tự có số 21 kèm nhãn BẢN NHÁP. Dựng thông thường không đưa bản nháp vào trang đọc. Chỉ chuyển published sau khi xử lý các điểm cần xác nhận và bổ sung ảnh/ngày.
Quy trình IIS hiện dùng gói GitHub Release. Commit hoặc PR chưa phải cập nhật IIS; workflow release chạy thủ công và tạo draft release. Không tự đổi DNS, SSL hoặc cấu hình IIS.

## Kiểm tra

Đối chiếu đầy đủ văn bản từng đoạn và ô bảng với Word; kiểm tra 8 ID bài duy nhất, 8 liên kết mục lục, tài nguyên cục bộ và dữ liệu 5 biểu đồ. Kết xuất A4 bằng WeasyPrint với phông thay thế để kiểm tra bố cục; không phát hành bản PDF kiểm tra. Môi trường thiếu Arial và Times New Roman nên chưa xác nhận dàn trang cuối với đúng phông. Chưa kiểm thử trình duyệt thật trên máy tính/điện thoại.
