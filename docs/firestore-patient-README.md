# Firestore 患者文档格式说明

## 模板文件

- **firestore-patient-template.json** — 与 Firestore `patients` 集合文档结构一致的新患者模板（文档 ID 建议用 `P-2025-005`，与 app 默认 Patient ID 一致）。

## 字段说明（与 P-2025-001 格式一致）

| 字段 | 类型 | 说明 |
|------|------|------|
| **address** | map | 地址：city, state, street, zipCode (string) |
| **assignedClinicianId** | string | 负责临床医生 ID |
| **createdAt** | string | ISO 8601 时间 |
| **dateOfBirth** | string | 出生日期 YYYY-MM-DD |
| **diagnosis** | array | 诊断名称字符串数组 |
| **email** | string | 邮箱 |
| **emergencyContact** | map | name, phone, relationship (string) |
| **firstName** | string | 名 |
| **gender** | string | male / female |
| **id** | string | 患者 ID，与文档 ID 一致（如 P-2025-005） |
| **lastContact** | string | ISO 8601 时间 |
| **lastName** | string | 姓 |
| **medications** | array | 药品对象数组，每项：name, dosage, frequency, startDate (string) |
| **phone** | string | 电话 |
| **riskLevel** | string | 如 high / medium / low |
| **status** | string | 如 active |
| **targetDiastolic** | number | 舒张压目标值 |
| **targetSystolic** | number | 收缩压目标值 |
| **updatedAt** | string | ISO 8601 时间 |

## 在 Firestore 中添加患者

1. 打开 Google Cloud Console → Firestore → 选择 `carelink` 项目。
2. 选中 **patients** 集合。
3. 点击 **+ Add document**。
4. **Document ID**：填写 `P-2025-005`（或你要用的 ID；app 里 Settings → Patient ID 需与此一致）。
5. 按模板逐字段添加：
   - **address**：类型选 **map**，再添加子字段 city, state, street, zipCode（均为 string）。
   - **diagnosis**：类型选 **array**，添加元素 0, 1, ...（string）。
   - **emergencyContact**：类型选 **map**，子字段 name, phone, relationship（string）。
   - **medications**：类型选 **array**，每个元素为 **map**，包含 name, dosage, frequency, startDate（string）。
   - **targetSystolic** / **targetDiastolic**：类型选 **number**。
   - 其余字段均为 **string**。
6. 或使用 Firebase Admin SDK / 脚本读取 `firestore-patient-template.json` 并写入 `patients/P-2025-005`。

## 与 App 的对应关系

- App 内 **Settings → Patient ID** 填写的 ID（默认 `P-2025-005`）会作为 `patientId` 随血压数据上传到后端。
- 后端将读数写入 `readings` 等集合时，会关联该患者；患者基本信息应已在 `patients/{patientId}` 中存在且格式与本模板一致。
