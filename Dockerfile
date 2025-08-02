FROM ubuntu:22.04

# 필요한 패키지 설치  
RUN apt update && \
    apt install -y software-properties-common wget curl git openssh-client python3 && \
    apt clean

# SSHX 설치 (공식 설치 스크립트 사용)
RUN curl -sSf https://sshx.io/get | sh

# 더미 인덱스 페이지 생성  
RUN mkdir -p /app && echo "SSHX Session Running..." > /app/index.html  
WORKDIR /app

# 포트 노출 (필요에 따라 변경)
EXPOSE 6080

# 컨테이너 시작 시 수행할 명령  
CMD bash -c "\  
    # 웹 서버 유지 (Railway가 컨테이너 활성화 위해 필요) \
    python3 -m http.server 6080 & \
    # SSHX 터널링 시작 (적절한 옵션으로 변경 필요) \
    sshx -L 8080:localhost:80 && \

    wait"
