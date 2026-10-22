# Đối chiếu bản nháp số 37/2026

Ngày xử lý: 23/10/2026 (Việt Nam). Chưa được duyệt xuất bản Production.

## Nguồn và mốc khôi phục

- Word: `01102026_BT37_Draft (1).docx`.
- SHA-256 Word: `ccb5d2589ad87b899d74e47f7ba442023d58e4719fa79677edf73ad2b0404a7a`.
- Quy trình: prompt ngày 22/10/2026 do người phụ trách gửi lại.
- Mẫu: `templates/issues/so-35-2026.html.j2` tại commit `855a892e657c064a213c3c74e8f6e4bc660f2179`, thay số/năm và nội dung; header/footer theo mẫu đã duyệt. Tiêu đề headline 1 dài nên giảm riêng xuống 11,5pt để giữ nguyên văn và vừa khung.
- Khôi phục entrypoint `build.py` từ mốc trên để workflow cũ `--include-drafts` tiếp tục dựng dữ liệu JSON và `public/`. Giữ nguyên `scripts/build.py`, `scripts/validate.py`, schema và dữ liệu YAML/Markdown của pipeline v2. Không reset lịch sử Git hay chạm IIS/Production. Tệp Preview số 01 hiện có không bị xóa bởi bước này.

## Kiểm kê nội dung

| Bài | Chuyên mục | Tiêu đề |
|---|---|---|
| 1 | Tin trong nước | Cục Phòng vệ thương mại tiếp nhận hồ sơ đầy đủ, hợp lệ yêu cầu điều tra chống bán phá giá đối với thép không gỉ cán nguội từ Trung Quốc, In-đô-nê-xi-a và Đài Loan – Trung Quốc |
| 2 | Tin trong nước | Nam Phi khởi xướng điều tra chống bán phá giá đối với xi măng Portland nhập khẩu từ Việt Nam và Mozambique |
| 3 | Tin trong nước | Liên minh Châu Âu (EU) áp dụng biện pháp tự vệ tạm thời đối với sản phẩm thép điện định hướng dạng hạt (GOES) |
| 4 | Tin nước ngoài | Úc đổi tên Ủy ban Chống bán phá giá thành Ủy ban Phòng vệ thương mại, tiếp nhận chức năng điều tra tự vệ |
| 5 | Tin nước ngoài | Ấn Độ khởi xướng điều tra chống bán phá giá đối với 7 sản phẩm của Trung Quốc, trong đó có nhiều nguyên liệu dược phẩm |
| 6 | Tin nước ngoài | Ấn Độ đề xuất áp dụng thuế chống bán phá giá đối với sản phẩm đồ thủy tinh borosilicate dùng cho bàn ăn và nhà bếp nhập khẩu từ Trung Quốc |
| 7 | Tin nước ngoài | Nam Phi áp dụng thuế chống bán phá giá chính thức đối với sản phẩm thép cuộn chống ăn mòn nhập khẩu từ Trung Quốc |
| 8 | Tin nước ngoài | Bra-xin khởi xướng điều tra chống bán phá giá đối với sản phẩm lưới thép nhập khẩu từ Trung Quốc |
| 9 | Tin nước ngoài | EU khởi xướng rà soát cuối kỳ biện pháp chống trợ cấp đối với sản phẩm thép không gỉ cán nguội từ Ấn Độ và In-đô-nê-xi-a |
| 10 | Thông tin xuất nhập khẩu | Cảnh báo đối với mặt hàng sợi dún polyester xuất khẩu vào thị trường Hoa Kỳ |

Nhóm C trong Word ghi “C. BÀI VIẾT”, được ánh xạ sang chuyên mục mẫu “THÔNG TIN XUẤT NHẬP KHẨU”. Không lặp ba nhãn chuyên mục hay tiêu đề bài trong thân bài. Bài 1 và bài 10 được chọn làm hai headline để người phụ trách xem.

## Ảnh và thông tin còn thiếu

| Tệp đề xuất | Vị trí | Mô tả để chọn ảnh, không phải chú thích gốc | Trạng thái |
|---|---|---|---|
| `bt37-2026-bia.jpg` | Khung ảnh bìa | Hoạt động xuất nhập khẩu/cảng biển phù hợp | Chưa nhận, chưa có nguồn/chú thích xác nhận |
| `bt37-2026-headline-1-thep-khong-gi-can-nguoi.jpg` | Headline 1 trên bìa; có thể dùng bài 1 nếu được duyệt | Thép không gỉ cán nguội, dạng tấm/cuộn phù hợp | Chưa nhận |
| `bt37-2026-headline-2-soi-dun-polyester.jpg` | Headline 2 trên bìa; có thể dùng bài 10 nếu được duyệt | Sợi dún polyester hoặc dây chuyền phù hợp | Chưa nhận |

Phần mở rộng chỉ là đề xuất; khi nhận PNG/JPEG phải giữ đúng định dạng thật. Word không chứa ảnh raster; có 5 biểu đồ nhúng, đã dựng lại từ chính dữ liệu cache của từng chart XML. Logo/QR cơ quan và nhân sự trang cuối giữ theo mẫu đã duyệt, chưa xác nhận lại cho kỳ này. Không có tên tác giả riêng cho từng bài trong phần văn bản Word; không lấy tên người tạo tệp ở metadata làm tác giả. Ngày phát hành để null; không suy từ tên tệp.

## Điểm nghiệp vụ cần người phụ trách kiểm tra

1. Cơ cấu năm 2024: biểu đồ nhúng chart2 có Ca-na-đa (khoảng 1,53%), trong khi bảng 2024/2025 liệt kê En-Xan-va-đo và không có Ca-na-đa. Tỷ lệ “các nguồn cung ứng khác” trong chart2 khoảng 3,67%; phạm vi top 10 không hoàn toàn trùng bảng. Giữ nguyên bảng và biểu đồ, chưa điều chỉnh danh sách hay tổng.
2. Bài cảnh báo có câu “Việt Nam đã gia tăng đáng kể xuất khẩu… trong những năm gần đây”; số liệu riêng 2025 và 8T/2026 lại giảm. Có thể đây là nhận định dài hạn/điều kiện, không đủ căn cứ coi sai; cần xem lại phạm vi thời gian diễn đạt. Không sửa.
3. Mã HS trong tin EU có khoảng trắng không đều giữa các nhóm số; giữ nguyên chữ/số theo Word để tránh tự thay mã nghiệp vụ. Cần xác nhận nếu muốn chuẩn hóa.
4. Bản này là chế bản từ tài liệu cung cấp; chưa thẩm định pháp lý, mức thuế hoặc tính cập nhật của các tin và nguồn bên ngoài.

## Chuẩn hóa đã thực hiện

- Một lỗi chính tả hiển nhiên “sản phầm” → “sản phẩm” tại đoạn tổng kết nguồn cung năm 2025.
- Bỏ khoảng trắng đầu/cuối đoạn và chuẩn hóa HTML, không đổi số liệu.
- URL đứng riêng trước tin EU được chuyển thành liên kết ở dòng “Tổng hợp từ steelorbis.com” của chính bài đó; địa chỉ được giữ nguyên. Không bịa thêm URL cho các nguồn chỉ ghi tên miền.
- Nguồn của 2 bảng và 5 biểu đồ nằm trong nhóm trực quan và căn giữa; dòng tổng hợp nguồn bài căn phải.

## Kiểm tra cục bộ và giới hạn

- Đối chiếu từng đoạn Word: PASS; đủ 10 tiêu đề và toàn bộ đoạn nội dung sau chuẩn hóa đã nêu. Hai bảng giữ nguyên toàn bộ ô; không có giá trị tự nội suy.
- Đủ 5 SVG và dữ liệu biểu đồ, kèm chart XML gốc để đối chiếu; XML không đưa vào gói website theo bộ đóng gói hiện có.
- Không còn ảnh tham chiếu sang số khác; ảnh chưa có được hiển thị bằng ô ghi rõ còn thiếu. Tài nguyên logo, QR và biểu đồ tham chiếu đều tồn tại.
- Đủ 10 footer bài, đúng số 37/2026; mục lục có 10 neo và 10 số trang.
- Dàn kiểm tra WeasyPrint: 46 trang A4. Các bài bắt đầu lần lượt tại 3, 4, 6, 7, 9, 12, 14, 16, 17, 19. Đã xem ảnh tổng thể các trang, bìa, mục lục, biểu đồ, bảng và trang cuối.
- Máy kiểm tra thiếu Arial/Times New Roman gốc, đang thay bằng font hệ thống. Các số trang là kết quả của bản dựng kiểm tra này, cần xác nhận lại trên môi trường font chuẩn sau khi đủ ảnh. Không phát hành PDF chính thức từ bản QA.
- Chưa kiểm tra trực quan trên trình duyệt thật, chưa xác nhận HTTP của nguồn ngoài, chưa xác nhận đã cập nhật IIS. Chưa được duyệt Production.
