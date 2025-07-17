# Clinical-TLF-Generation-Oncology-Trial
This repository showcases the generation of Tables, Listings, and Figures (TLFs) from ADaM datasets for an oncology clinical trial using CDISC standards. It includes Base SAS programs to produce safety summary tables such as AE Severity, following regulatory and submission-ready formats.


# TLF Generation – Oncology Breast Cancer Clinical Trial (CDISC Standards)

This repository demonstrates the generation of **Tables, Listings, and Figures (TLFs)** using SAS from CDISC-compliant **ADaM datasets**, specifically for an **Oncology Phase I Breast Cancer Clinical Trial**. It is a continuation of the SDTM and ADaM mapping projects previously completed.

---

## 📁 Repository Structure

TLF-Oncology-Project/
│
├── Raw_ADaM/ --> Input ADaM datasets (e.g., ADAE)
├── TLF_Specs/ --> Mock shells and table specifications
├── Programs/ --> SAS programs used to create tables
├── Output/ --> Final output tables (RTF, PDF, or SAS dataset format)
└── README.md --> Project documentation (this file)

## 📌 Objective

To create submission-ready summary tables from ADaM datasets using **Base SAS**, focusing on:
- Adverse Event severity summary (e.g., mild, moderate, severe)
- Clear presentation of clinical results
- Adherence to industry standards (CDISC, ICH E3)

---

## 🛠️ Tools and Standards

| Component         | Details                                |
|------------------|----------------------------------------|
| **Software**      | SAS 9.4                                 |
| **Standards Used**| CDISC (ADaM 1.1, SDTM 3.2)              |
| **Study Phase**   | Phase I                                 |
| **Therapeutic Area** | Oncology (Breast Cancer)             |
| **Inputs**        | ADaM.ADAE dataset                       |
| **Output Format** | RTF / SAS Dataset                       |

---

## 🧾 Table Example: AE Severity Summary Table

| AETOXGR (Severity) | Count (n) | Percentage (%) |
|--------------------|-----------|----------------|
| Mild               | 5         | 25.0%          |
| Moderate           | 10        | 50.0%          |
| Severe             | 5         | 25.0%          |
| **Total**          | **20**    | **100.0%**     |

> This table was generated using `PROC REPORT` in SAS from the ADAE dataset.

---

## ✅ Steps Followed

1. **Input Preparation**
   - Used ADAE dataset from previous ADaM project.
   - Verified required variables (e.g., AETOXGR, USUBJID).

2. **Table Shell Design**
   - Created based on TLF mock shells provided in the TLF_Specs folder.

3. **SAS Programming**
   - Used `PROC FREQ`, `PROC SUMMARY`, and `PROC REPORT` for table generation.

4. **Output Generation**
   - Exported output in `.sas7bdat` and `.rtf` formats into the Output folder.

---

## 📂 Folder Details

### 🔹 Raw_ADaM/
- `adae.sas7bdat`: Input dataset with adverse event data

### 🔹 TLF_Specs/
- `AE_Severity_Summary_Shell.docx`: Table shell/sample layout
- `TLF_Specification.xlsx`: Table metadata (e.g., variable mapping, sorting order)

### 🔹 Programs/
- `tlf_ae_severity.sas`: Main program used to generate the AE summary table

### 🔹 Output/
- `ae_severity_summary.sas7bdat`
- `ae_severity_summary.rtf` *(if exported)*

---

## 👩‍💻 Author Information

**Prasanthi Kata**  
Clinical SAS Programmer (Intern)  
📎 [GitHub Portfolio](https://github.com/Prasanthi-sas)  

---

## 🔗 Related Projects

- [SDTM Mapping – Breast Cancer Oncology Trial](https://github.com/Prasanthi-sas/End-to-End-SDTM-Mapping-Using-SAS-for-a-Phase-I-Oncology-Breast-Cancer-Clinical-Trial)
- [ADaM AE Dataset – Oncology Trial Extension](https://github.com/Prasanthi-sas/ADaM-AE-Mapping-Oncology-SDTM-Extension)

## 🧠 Key Learnings

- Translating statistical specifications into TLFs
- Using `PROC REPORT` for CSR-ready table outputs
- Understanding the importance of traceability from raw to SDTM → ADaM → TLF

