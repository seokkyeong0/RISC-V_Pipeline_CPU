## RISC-V RV32I 5-Stage Pipeline CPU Core

### 📌 프로젝트 개요

- **목표**
    
    RISC-V RV32I 기반 5-Stage Pipeline CPU를 RTL로 직접 설계하며, Pipeline 구조에서 발생하는 Hazard와 분기 성능 문제를 설계 관점에서 해결
    
- **주요 내용**
    - 5-Stage Pipeline CPU Core 설계 (IF–ID–EX–MEM–WB)
    - Data / Control Hazard 분석 및 Forwarding, Stall Logic 구현
    - 2-bit Dynamic Branch Predictor 설계 및 성능 비교 분석
- **개발 환경**
    
    `SystemVerilog`, `C`, `RISC-V`
    

---

### ⚙️ Pipeline CPU 아키텍처

- **구조**
    
    IF → ID → EX → MEM → WB로 구성된 5-Stage Pipeline Datapath 설계
    
- **설계 방식**
    
    Stage 간 데이터 및 제어 신호 전달을 위해 Pipeline Register를 명확히 분리하여 구현
    
    각 Stage의 역할과 타이밍을 기준으로 Datapath와 Control Logic을 구조적으로 설계
    
- **설계 목표**
    - Pipeline 동작 원리 및 Hazard 발생 원인을 RTL 수준에서 이해
    - **80~100MHz 이상의 Clock Frequency**에서 안정적인 동작 확보

---

### 🧠 핵심 Logic 설계

- **Data Hazard 처리**
    - rs1 / rs2 / rd 의존성 분석
    - EX/MEM, MEM/WB 단계 결과를 활용한 Forwarding Logic 설계
    - Load-Use 상황에서 Stall 삽입 로직 구현
- **Control Hazard 처리**
    - Branch / Jump 명령어에 대한 Flush 제어 로직 설계
    - 분기 결정 시 Pipeline 오동작 방지를 위한 제어 신호 정합
- **Dynamic Branch Predictor**
    - 2-bit Saturating Counter 기반 분기 예측기 설계
    - Predictor 상태와 Pipeline Register 간의 연동 구조 구현

---

### 🧪 시뮬레이션 및 디버깅

- 분기 예측 적용 전 / 후 성능 비교를 통해 Predictor 효과 검증
- Register File이 이전 값을 읽는 문제 발생
    
    → Internal Forwarding Logic 추가로 해결
    
- 명령어 간 rs1, rs2, rd 필드 겹침으로 의도치 않은 신호 활성화 문제 발생
    
    → MUX 제어 로직 보완으로 해결
    
- Pipeline 제어 신호 타이밍 불일치로 인한 오동작 발생
    
    → Stage별 제어 신호 재정렬 및 Pipeline Register 기준으로 제어 흐름 재구성
    
- Branch 처리 시 잘못된 PC 업데이트로 인한 문제 발생
    
    → Flush 조건 명확화 및 Wire 연결 점검 후 개선
    

---

### 🚀 프로젝트 성과 및 개선 방향

- Pipeline CPU의 명령어 실행 흐름과 Hazard 처리 메커니즘에 대한 **설계 수준 이해 확보**
- 2-bit Dynamic Branch Predictor 적용을 통한 **B-Type 명령어 성능 개선**
- **향후 개선 방향**
    - Clock Frequency 향상을 위한 **6-Stage 구조(IF–ID–EX1–EX2–MEM–WB)** 확장 설계
    - Cache Memory 등 메모리 접근 지연 최소화 모듈 설계

---

### 🙋‍♂️ 개인 기여도

- 5-Stage Pipeline CPU Core 전체 RTL 설계
- Hazard 분석 및 Forwarding / Stall / Flush Logic 직접 구현
- Branch Predictor 설계 및 성능 비교 분석 수행
