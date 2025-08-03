#!/bin/bash

# --- 1. SSH 서버 시작 ---
# -D 옵션은 SSH 데몬이 백그라운드에서 실행되고, 현재 셸 세션과 연결되지 않도록 합니다.
# 이렇게 해야 start.sh 스크립트가 다음 명령어를 계속 실행할 수 있습니다.
echo "Starting SSH server..."
/usr/sbin/sshd -D &

# --- 2. PufferPanel 시작 ---
# PufferPanel은 systemd를 사용하지 않으므로 직접 실행해야 합니다.
# PufferPanel 바이너리가 /usr/bin/pufferpanel 에 설치되었다고 가정합니다.
# '&' 를 사용하여 백그라운드에서 실행하여 스크립트가 멈추지 않도록 합니다.
echo "Starting PufferPanel..."
/usr/bin/pufferpanel run &

# --- 3. PufferPanel 관리자 계정 생성 (선택 사항 - 최초 실행 시에만) ---
# 이 부분은 컨테이너가 처음 시작될 때 PufferPanel 관리자 계정을 생성하는 코드입니다.
# 한번만 실행되도록 /server/.pufferpanel_admin_set 파일을 활용합니다.
# YOUR_USERNAME, YOUR_EMAIL, YOUR_PASSWORD 부분을 실제 사용할 정보로 변경해주세요.
# 비밀번호는 강력하게 설정하는 것이 중요합니다!
if [ ! -f /server/.pufferpanel_admin_set ]; then
  echo "Creating PufferPanel admin user..."
  # 아래 주석을 풀고 YOUR_USERNAME, YOUR_EMAIL, YOUR_PASSWORD를 실제 값으로 바꾸세요.
  # 예시: pufferpanel user add --username myadmin --email myemail@example.com --password MySuperSecurePassword! --admin
  pufferpanel user add --username Yooniverse --email choyooniverse011@outlook.kr --password Yooniverse-011!! --admin
  # touch /server/.pufferpanel_admin_set # 계정 생성 후 마커 파일 생성
  echo "PufferPanel admin user creation skipped. Please create manually or uncomment the line."
fi

# PufferPanel이 완전히 시작될 때까지 잠시 대기 (선택 사항이지만 안정성 향상)
sleep 5

# --- 4. 마인크래프트 서버 시작 ---
# Java 서버를 실행합니다. -Xmx, -Xms 옵션으로 할당할 RAM 크기를 설정할 수 있습니다.
# Railway에서 할당한 RAM에 맞춰 설정하세요. 여기서는 4GB 예시입니다.
# nogui 옵션은 그래픽 사용자 인터페이스 없이 서버를 실행합니다.
echo "Starting Minecraft server..."
java -Xmx4G -Xms4G -jar paper.jar nogui

# 중요: Minecraft 서버가 종료되면 이 스크립트도 종료되고, 컨테이너도 종료됩니다.
# 만약 PufferPanel이 계속 실행되고 Minecraft 서버를 PufferPanel이 관리하게 하려면,
# java -jar paper.jar nogui 대신 `tail -f /dev/null` 같은 명령어를 마지막에 넣어
# 컨테이너가 종료되지 않고 계속 실행되도록 해야 합니다.
# 그 후 PufferPanel 웹 인터페이스에서 Minecraft 서버를 추가하고 시작해야 합니다.
# 지금은 간편하게 Minecraft 서버가 컨테이너의 주 프로세스라고 가정합니다.
