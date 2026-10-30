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

## Bảng ánh xạ ảnh

| Tệp | Vị trí | Chú thích |
|---|---|---|
| cover.jpg | Bìa | Cảng biển và tàu container; Journal of Commerce |
| steel.jpg | Headline 1; bài 1 | Thép cán nguội dạng cuộn; VCM Steel Sheet |
| pork.jpg | Bài 2 | Các sản phẩm thịt lợn; Knorr Philippines |
| pet.jpg | Bài 3 | Hạt nhựa PET; Henan Chemger / Made-in-China |
| foil.jpg | Bài 4 | Lá nhôm tạo hình nguội dùng cho bao bì dược phẩm; HW Aluminum |
| titanium.jpg | Bài 5 | Bột titan đi-ô-xít; Chemi Enterprises |
| cannabis.jpg | Bài 6 | Cơ sở trồng cần sa phục vụ y tế tại Úc; ABC News |
| octg.jpg | Bài 7 | Ống thép dùng trong ngành dầu khí; Cangzhou Steel Pipe Group |
| galvanized.jpg | Bài 8 | Thép mạ kẽm dạng cuộn; Made-in-China |
| stainless.jpg | Bài 9 | Thép không gỉ cán nguội; JMX Steel / Made-in-China |
| pencils.jpg | Headline 2; bài 10 | Bút chì gỗ; The Little Wooden Peg |

## Đã kiểm chứng ngày 30/10/2026

- Đối chiếu toàn bộ đoạn văn và ô bảng với Word: đạt, không thiếu nội dung.
- 25 tệp triển khai kiểm tra SHA-256 trước và sau copy: đạt.
- HTTP loopback: 200. HTTPS mở trên trình duyệt: đúng số 41/2026.
- DOM trình duyệt: 10 article, 2 table, 22 vị trí ảnh (gồm logo/QR, ảnh lặp và 5 biểu đồ), tất cả tải thành công sau khi trang hoàn tất tải.
- Sao lưu: `C:\BanTinAgent\backup\preview-so41-20261030-104013`.
- Nội dung triển khai từ commit `6bd073711ee4a1669870346ad23152b7f2fddb0e`, nhánh `preview/so-41-2026-20261030`; PR #34 ở trạng thái draft.
- URL: https://bantin.trav.gov.vn/ban-tin-moi/so-41-2026.html
- Chỉ cập nhật index và số 41 trong thư mục preview, không sửa production hay cấu hình máy chủ.

## Điều chỉnh theo yêu cầu mới nhất
- Headline 1 đổi sang bài PET (bài 3), ảnh headline dùng pet.jpg và liên kết #article-3.
- Xóa toàn bộ 10 ảnh minh họa và chú thích trong thân bài; giữ 2 bảng và 5 biểu đồ nguồn Word.
- Giữ ảnh bìa và hai ảnh headline. Mục lục tính lại sau khi bỏ ảnh.
- Các ghi nhận ảnh thân bài phía trên là lịch sử trước điều chỉnh này.

## Điều chỉnh tiếp theo theo ảnh đánh dấu
- Thêm riêng ảnh thép cán nguội vào cuối bài 1; khung ảnh cao 112mm, vừa trang A4. Các bài còn lại không có ảnh minh họa.
- Nội dung chính: chữ 14pt.
- Bài bút chì: khôi phục mục 1 (mô tả), 2 (xuất khẩu thế giới), 3 (xuất khẩu Việt Nam), 4 (cảnh báo); quy trình và thị trường đánh số phụ 1.1, 1.2.
- Đã dựng lại mục lục và kiểm tra mục lục một trang, bài 1 một trang A4.
