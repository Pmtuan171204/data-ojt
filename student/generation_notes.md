# Quy tắc mô phỏng và phân bổ

- Tổng 3.000 sinh viên; mỗi khóa K19/K20/K21 có 1.000, mỗi chuyên ngành có 750. Mỗi cặp khóa–chuyên ngành có 250 sinh viên.
- Giữ mã, tên, khóa và chuyên ngành của 2.000 sinh viên cũ. Thêm 1.000 sinh viên, tên được sinh giả lập và có thể trùng tên; mã sinh viên không trùng.
- Mã SE190000–SE190999, SE200000–SE200999, SE210000–SE210999. Tiền tố SE dùng cho tất cả chuyên ngành theo yêu cầu.
- Email được đồng bộ theo mã và dùng tên miền example.com cho dữ liệu mô phỏng.
- Chia đều 250 sinh viên theo các nhóm nhập học có khung xác nhận trong từng khóa–chuyên ngành, chênh lệch tối đa 1 người. Nếu một nhóm có nhiều bản khung, tiếp tục chia đều giữa các bản, chênh lệch tối đa 1 người.
- Phân bổ giữa bản thường và `_FNO`, hoặc IS K20D và IS K20D-21A, chỉ là giả định mô phỏng được lựa chọn để rải đều; chưa phải xác nhận đối tượng áp dụng thực tế của trường. Không diễn giải ý nghĩa `_FNO` hoặc suy ra hiệu lực thay thế.
- IS K21 chỉ có nhóm A theo phạm vi đã thống nhất. IA K19 không có C theo xác nhận người dùng. AI K19 tạm chỉ phân bổ A/B/D vì chưa có nguồn cho C, không kết luận trường không có AI K19C.
- K19 A/B: kỳ 5, C/D: kỳ 4. K20 A: kỳ 4, B/C: kỳ 3, D: kỳ 2. K21 A/B: kỳ 2, C/D: kỳ 1.
- Tín chỉ chỉ tính kỳ đã hoàn thành: `(kỳ hiện tại - 1) × 15 - số môn chưa đạt × 3`. Kỳ 1 bằng 0; từ kỳ 2 mô phỏng thiếu 0/1/2/3 môn với xác suất 60%/25%/10%/5%. Chưa mô phỏng học vượt hay miễn môn.
- Dùng seed cố định 20261005. Script `student.mjs` đọc các CSV khung hiện có, tổng hợp 40 mã và cập nhật sinh viên; chạy lại trên 3.000 dòng không thêm 1.000 dòng nữa.
- Bản sao trước chỉnh sửa: `backups/student_before_curriculum_sync.csv`.
- Kiểm tra: 3.000 mã/email duy nhất, số lượng theo khóa/chuyên ngành, đủ dải mã mỗi khóa, tất cả mã khung có trong bảng tổng hợp và đúng chuyên ngành/nhóm khóa, tín chỉ không âm/chia hết 3/không vượt số kỳ hoàn thành. Cả 40 mã khung đều được sử dụng.
