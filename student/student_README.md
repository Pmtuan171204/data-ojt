# Ý nghĩa các cột trong student.csv

| Cột | Ý nghĩa |
|---|---|
| `student_id` | Mã số sinh viên gồm tiền tố `SE` cho mọi sinh viên và 6 chữ số: 2 số đầu là khóa, 4 số sau là số thứ tự bắt đầu từ `0000` và đếm lại khi sang khóa mới. Ví dụ: `SE190595`. |
| `full_name` | Họ và tên sinh viên. |
| `email` | Email mô phỏng theo mã sinh viên, dạng `ojt.synthetic.se190000@example.com`; không phải email liên hệ thực tế. |
| `cohort` | Khóa sinh viên: `K19`, `K20` hoặc `K21`. |
| `major` | Ngành học của sinh viên, hiện là Công nghệ thông tin. |
| `specialization` | Chuyên ngành: Hệ thống thông tin, An toàn thông tin, Kỹ thuật phần mềm hoặc Trí tuệ nhân tạo. |
| `curriculum_code` | Mã khung áp dụng, liên kết với `curriculum/curricula_all.csv`. Giữ đúng mã nguồn, kể cả `_FNO`, dấu gạch nối/gạch dưới và `SE-2026`. Khung có thể áp dụng cho một nhóm hoặc nhóm ghép D–A. |
| `current_semester` | Kỳ học hiện tại: K19 thuộc kỳ 4–5, K20 thuộc kỳ 2–4, K21 thuộc kỳ 1–2. |
| `accumulated_credits` | Số tín chỉ đã tích lũy từ các kỳ hoàn thành trước kỳ hiện tại. Mỗi môn 3 tín chỉ, mỗi kỳ 5 môn, tối đa 15 tín chỉ/kỳ; chưa tính các môn chưa đạt. |
