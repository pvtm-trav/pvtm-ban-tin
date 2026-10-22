# Bản tin 01/2026 - Preview QA

- Nguồn: `15012026_BT01_Draft.docx` (23 trang)
- Trạng thái: draft / preview only
- Nội dung: 11 bài, 2 bảng, 5 biểu đồ
- Ba chuyên mục: TIN TRONG NƯỚC; TIN NƯỚC NGOÀI; THÔNG TIN XUẤT NHẬP KHẨU
- Hai tin nổi bật: bài thép cây Việt Nam/Vương quốc Anh; bài đồ nội thất phòng ngủ/Hoa Kỳ
- Ảnh bìa: CHƯA XÁC NHẬN
- Ảnh nổi bật 1: CHƯA XÁC NHẬN
- Ảnh nổi bật 2: CHƯA XÁC NHẬN
- Ngày phát hành: CHƯA XÁC NHẬN
- Bản render A4 kiểm tra: 30 trang
- Tên tệp Preview chuẩn: `so-01-2026.html`
- SHA256 bản HTML đã dựng: `eab389daebf52de2fef60f05465ee20ac931a43048579a3e88916806be79ebbd`

## Cảnh báo nội dung giữ nguyên để duyệt

1. Word có tiêu đề EU/lốp xe với chuỗi `hủy bỏkhông áp dụng`; cần người duyệt xác nhận cách sửa.
2. Word ghi nhập khẩu đồ nội thất phòng ngủ của Hoa Kỳ năm 2023 là 3,3 tỷ USD, năm 2024 là 3,5 tỷ USD nhưng mô tả `tiếp tục giảm`.
3. Word ghi các nguồn cung ứng khác năm 2023 đạt `255,5 nghìn USD`, chiếm 7,8%; cần kiểm tra đơn vị.
4. Đoạn xuất khẩu đồ nội thất phòng ngủ của Việt Nam ghi `sang thị trường EU` dù toàn bộ ngữ cảnh là Hoa Kỳ; chưa tự sửa.

## QA trình bày

- A4 render được 30 trang bằng WeasyPrint.
- Mục lục: bài đầu các nhóm bắt đầu ở trang 3, 7, 19; các số trang hiển thị trong mục lục đã được đối chiếu với bản render hiện tại.
- Font bản dựng đã được ép thống nhất Arial.
- Nguồn bảng/biểu đồ căn giữa; nguồn/tác giả bài viết căn phải.
- Production chưa được phép cập nhật trước lệnh `duyệt xuất bản`.
