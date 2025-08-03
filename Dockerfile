FROM eclipse-temurin:21-jre

WORKDIR /server

# 필요한 패키지(curl, openssh-server)를 설치합니다.
# 모든 설치 관련 명령어를 하나의 RUN 블록으로 묶고, sudo를 제거합니다.
RUN apt-get update \
    && apt-get install -y curl openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash \
    && apt-get install -y pufferpanel

# systemctl enable --now pufferpanel 와 pufferpanel user add 는 컨테이너 빌드 시점이 아닌,
# 컨테이너가 실행될 때 (start.sh) 실행되어야 합니다.

# SSH 서버를 설정합니다.
RUN mkdir -p /var/run/sshd # -p 옵션 추가: 이미 존재하면 오류 없음
RUN useradd -ms /bin/bash minecraft && echo "minecraft:password" | chpasswd
# 보안상 PermitRootLogin yes는 매우 위험합니다. 테스트 목적으로만 사용하고 실제 서비스에서는 절대 권장하지 않습니다.
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Paper 서버 JAR 파일을 다운로드합니다. (최신 1.20.1 버전 예시)
# 현재 날짜 기준 (2025년 8월 3일) 1.21.8 버전 URL을 확인했습니다.
# 이 URL은 PaperMC 사이트에서 직접 확인하고 복사하는 것이 가장 정확합니다.
RUN curl -o paper.jar https://fill-data.papermc.io/v1/objects/4bee8c5b1418418bbac3fa82be2bb130d8b224ac9f013db8d48823225cf6ed0a/paper-1.21.8-21.jar


# 서버 시작 스크립트를 컨테이너에 복사합니다.
COPY start.sh .
RUN chmod +x start.sh

# 마인크래프트 포트와 SSH 포트(22)를 노출합니다.
EXPOSE 19132 22

# 컨테이너가 시작될 때 start.sh 스크립트를 실행합니다.
CMD ["./start.sh"]
