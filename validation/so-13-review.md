# Kiểm tra chế bản số 13 năm 2026

Trạng thái: PREVIEW. Chưa được duyệt xuất bản Production.

## Nguồn và nội dung

Tài liệu gốc: 170426_BT013.docx. Số 13 và năm 2026 được xác định từ tên tệp và ngữ cảnh trong tài liệu. Ngày phát hành chính thức chưa được nêu; không tự coi ngày 17/4/2026 trong tên tệp là ngày phát hành.

Có 10 bài: 3 tin trong nước, 6 tin nước ngoài, 1 bài thông tin xuất nhập khẩu. Có 2 bảng và 5 biểu đồ Word. Không có ảnh nhúng trong tài liệu hoặc ảnh đính kèm riêng.

Giữ nguyên nội dung, số liệu, mã HS, tên cơ quan/chuyên viên và dòng nguồn. Chỉ loại chuỗi giao diện thừa “Top of FormBottom of Form” ở cuối đoạn số 9; việc này được ghi trong so-13-source.json. Không sửa các mâu thuẫn nghiệp vụ.

## Đối chiếu thiết kế

Dùng mẫu 39 đã đối chiếu ở số 14, không tạo giao diện mới. Màn hình hiển thị 10 bài liền mạch. Kiểm tra Chrome cùng viewport 1100px: 8 nhóm thông số trùng mẫu 39, gồm số báo Anton, masthead Arial, headline bìa Times New Roman, mục lục 12pt, tiêu đề Arial 16pt, nội dung Times New Roman 14pt/cách đoạn 3mm, footer 10pt hết khổ trang và nhãn chuyên mục nền xanh 65mm. Font Anton tải thành công, không có ảnh lỗi.

Bản in Chrome A4 có 25 trang; mục lục theo các đích liên kết PDF: 3, 5, 7, 8, 9, 10, 11, 12, 13, 14. Nguồn bảng/biểu đồ căn giữa; nguồn bài căn phải. Dữ liệu biểu đồ lấy trực tiếp từ cache OOXML, không nhập lại bằng suy đoán và không biến ô trống thành 0.

## Bảng ảnh và biểu đồ

| Tệp | Vị trí | Chú thích/nguồn |
|---|---|---|
| cover.jpg | Bìa | Cảng hàng hóa — ảnh minh họa; Thanh Niên |
| feature1.jpg | Headline 1 | Thép mạ kẽm — ảnh minh họa; Hoa Sen Group/Vietnam Steel |
| feature2.jpg | Headline 2 | Sợi polyester độ bền cao — ảnh minh họa; Zhejiang Guxiandao/Made-in-China |
| chart1.svg | Bài 10 | Tổng nhập khẩu EU 2023–2025; Word/S&P Global |
| chart2.svg | Bài 10 | Cơ cấu nguồn cung 2024; Word/S&P Global |
| chart3.svg | Bài 10 | Cơ cấu nguồn cung 2025; Word/S&P Global |
| chart4.svg | Bài 10 | Việt Nam 2023–2025; Word/S&P Global |
| chart5.svg | Bài 10 | Việt Nam tháng 1/2025–tháng 1/2026; Word/S&P Global |

Ảnh bổ sung tìm trên Internet là minh họa sản phẩm, không phải bằng chứng về vụ việc. URL ảnh và trang nguồn được lưu trong assets/issues/so-13-2026/photo-sources.json.

## Điểm cần người phụ trách kiểm tra

1. Bài Úc: câu “Cục Phòng vệ thương mại sẽ tiếp tục phối hợp với Thương vụ Việt Nam tại Úc và nguồn thông tin từ để thông báo...” thiếu thành phần sau “từ”. Giữ nguyên, cần tác giả xác nhận.
2. Bài Hàn Quốc: “Cuộc điều tra được khởi xướng vào tháng 11” không nêu năm. Không tự gán năm.
3. Bài sợi polyester: đoạn năm 2024 so sánh với năm 2022, trong khi diễn biến liền trước là 2023. Giữ nguyên.
4. Bài sợi polyester: câu năm 2025 nêu “tổng kim ngạch xuất khẩu ... của EU” trong phần mô tả Việt Nam. Giữ nguyên, cần tác giả xác nhận chủ thể.
5. Dữ kiện về các quyết định, mức thuế và lịch vụ việc là nội dung tác giả cung cấp tại thời điểm tài liệu; chưa đối chiếu lại nguồn nghiệp vụ để thay thế hoặc cập nhật.
6. Ngày phát hành và ảnh do người dùng cung cấp chưa có; ảnh Internet được dùng có ghi nguồn.

## Phạm vi phát hành

Chỉ cập nhật số 13, tài nguyên của số 13 và thêm liên kết vào danh mục Preview hiện hữu. Không ghi đè những số khác. Có backup trước Publish. Chỉ thực hiện Production sau khi người dùng duyệt rõ đúng full commit SHA cuối; mọi commit thay đổi đều cần Preview mới.
