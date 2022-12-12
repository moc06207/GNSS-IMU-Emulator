# GNSS-IMU-Emulator

### Introduction
- 본 개발은 정보통신기획평가원(IITP)의 '현실-가상정보 융합형 엣지기반 자율주행 시뮬레이션SW 기술개발' 연구에 대한 일부 
- 본 개발은 자율주행 드라이빙 시뮬레이터에 대한 GNSS/IMU에 대해 현실에서 발생하는 오차 요인을 모델링하여 오차를 생성하는 코드임 


### GNSS

### IMU 

### Driving Simulator

- "MORAI" 드라이빙 시뮬레이터를 이용하여 사용방법을 설명함

#### 1. 드라이빙 시뮬레이터

![1](https://user-images.githubusercontent.com/80453237/206969052-007d314a-7f73-44a5-90f6-284785d709c6.JPG)

#### 2. 드라이빙 시뮬레이터 실행

![2](https://user-images.githubusercontent.com/80453237/206969229-56206e63-b988-435c-87e3-e08c9b8c0cf8.JPG)

#### 3. GPS/IMU 센서 설치

- 드라이빙 시뮬레이터에서 제공하는 센서를 차량에 설치함

- 사용자의 목적에 따라 센서의 위치를 가변적으로 구성

- GPS와 IMU를 상호 운용할 경우 이를 고려하여 센서를 배치해야함

![3](https://user-images.githubusercontent.com/80453237/206969277-1e653d75-9060-47b3-90ec-25cf735da4d4.JPG)

#### 3. GPS/IMU 센서 세부 설정 및 통신 프로토콜 설정

- 드라이빙시뮬레이터가 제공하는 센서 설정 기능을 이용함

- 통신 방식에 따라 사용자는 해당 코드를 이용하기 위해 드라이빙 시뮬레이터의 통신 프로토콜에 맞게 가변적으로 코드를 수정해야함

- 드라이빙시뮬레이터의 센서 출력 주기는 사전에 센서 설정에서 정의함

![4](https://user-images.githubusercontent.com/80453237/206969465-2dd7075c-ee1f-454b-8363-168573ab6d68.JPG)
![5](https://user-images.githubusercontent.com/80453237/206969468-e8abb951-9b50-40e9-9dc1-e268b07dfb92.JPG)
 
 #### 4. Emulater on
 
 - 코드를 실행하기 위해 드라이빙 시뮬레이터 프로토콜에 맞춰 데이터 수신 및 이를 가공할 수 있도록 사전에 사용자가 정의해야함 
 
 ![7](https://user-images.githubusercontent.com/80453237/206980723-50dac708-de24-48c4-b3bd-49fd93e7c873.JPG)
 
 #### 5. Results
 
![8](https://user-images.githubusercontent.com/80453237/206981182-9fea08ce-9d50-4370-9734-6503097bf6e3.JPG)


### Acknowledgement

- 본 개발은 2022년도 정부 (과학기술보통신부)의 재원으로 정보통신기획평가원의 지원을 받아 수행된 연구임 (No. 2021-0-01414, 현실-가상정보 융합형 엣지기반 자율주행 시뮬레이션SW 기술개발).
 
