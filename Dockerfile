FROM ubuntu:22.04

# 필요한 패키지 설치  
RUN apt update && \
    apt install -y software-properties-common wget curl git openssh-client python3 && \
    apt clean

# sshx 설치  
RUN curl -sSf https://sshx.io/get | sh

# 더미 인덱스 페이지 생성  
RUN mkdir -p /app && echo "SSHX Session Running..." > /app/index.html  
WORKDIR /app

# 포트 노출  
EXPOSE 6080

# 시작 명령  
CMD bash -c "\  
    # 간단한 웹 서버  
    python3 -m http.server 6080 & \
    # sshx 터널링 실행  
    sshx && \

    wait"
