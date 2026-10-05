# Ý nghĩa các cột trong courses/<curriculum_code>.csv

| Cột | Ý nghĩa |
|---|---|
| `curriculum_code` | Mã khung lấy từ nội dung HTML, dùng liên kết với bảng khung và sinh viên. |
| `course_code` | Mã môn hoặc nhóm học phần nguyên bản, giữ dấu `*`, dấu gạch dưới và chữ hoa/thường. |
| `course_name` | Tên môn nguyên bản, chỉ chuẩn hóa khoảng trắng. |
| `semester` | Kỳ dự kiến theo khung; có thể bằng 0. |
| `credits` | Số tín chỉ của dòng học phần trong khung, giữ đúng nguồn. |
| `prerequisite` | Nội dung điều kiện tiên quyết nguyên bản. Ô trống là nguồn để trống; `None` là nguồn ghi rõ `None`, không gộp hai trường hợp. |
