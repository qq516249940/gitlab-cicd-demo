#!/bin/bash
# . /etc/profile

Run_User="deployer"

#deployer用户运行脚本,避免后面代码不必要的执行,放在脚本最前面
if [ `whoami` != "$Run_User" ]; then
	echo "only $Run_User can run !!!"
	exit 1
fi

#基础目录
Base_Dir="/data/deploy"
#服务名称,外部传参
Service_Name=$2
#jar包完整路径
Service_Path="${Base_Dir}/${Service_Name}/${Service_Name}.jar"
#Pid文件路径
Service_Pid="${Base_Dir}/${Service_Name}/${Service_Name}.pid"
#日志目录
Log_Path="/data/logs/$Service_Name"
#脚本执行日志
Shell_Log="${Log_Path}/start.log"
#当前时间,记录脚本执行时间
Time_Now=`date +"%F %T"`
#APM监控包地址
#Apm_Path="/apm/cloudwise/JavaAgent_2.2.2/lib/CAgent-1.0.0.jar"

#*****手动修改项*****
#JVM参数,-参数
JAVA_OPTS="-server -Xms512m -Xmx512m"
#JAR包参数,--参数
JAR_OPTS=""

init(){
	#检测java环境
	tmp_var=`which java 2>/dev/null`
	if [ $? -ne 0 ];then
		echo "JDK缺失"
		exit 1
	else
		Java_Path=$tmp_var
	fi
	#服务名不为空
	if [ ! -n "$Service_Name" ];then
		echo "Service_Name服务名不能为空"
		exit 1
	fi
	#检查jar包文件是否存在
	tmp_var=`ls $Service_Path 2> /dev/null`
	if [ $? -ne 0 ];then
		echo "未知应用:$Service_Path"
		exit 1
	fi
	#监控文件检查
	#tmp_var=`ls $Apm_Path 2>/dev/null`
	#if [ $? -ne 0 ];then
	#	echo "监控文件不存在$Apm_Path"
	#	exit 1
	#fi
	#检查日志路径是否存在及可写
        tmp_var=`ls $Log_Path 2>/dev/null`
        if [ $? -ne 0 ];then
                echo "日志目录不存在$Log_Path"
                mkdir -p $Log_Path
        fi
	if [ ! -w $Log_Path ];then
		echo "$Log_Path无权限写入"
		exit 1
	fi
	#获取jvm参数
	if [ -f /data/scripts/.appjvm ];then
		if [ "$Service_Name" == "" ];then
			echo "参数错误:err_code 1"
			exit
		fi
		while read line;do
			tmp=`echo $line | awk -F ',' '{print $1}'`
			tmp=`echo $tmp | grep -v grep | egrep -e  ^"$Service_Name"$`
			if [ $? -eq 0 ];then
				JAVA_OPTS=`echo $line | awk -F ',' '{print $2}'`
				JAR_OPTS=`echo $line | awk -F ',' '{print $3}'`
			fi
		done < /data/scripts/.appjvm
	fi

}

#初始化psid变量(全局)
#检查包运行的状态。1、psid=0 表示程序未运行；2、 检查出来一个包,psid=pid
checkpid() {
	#通过包名和端口ps出1个进程。则返回进程的pid
	if [ `ps -ef | grep -Ev "grep|$0" | grep -c "$Service_Path" ` -eq 1 ]; then
		javaps=`ps -ef | grep -v grep | grep "$Service_Path"  | awk '{print $2}'`
		if [ -n "$javaps" ]; then
			psid=`echo $javaps`
		else
			echo "checkpid异常"
			exit 1
		fi
	#通过包名和端口ps出多个进程。则脚本停止退出
	elif [ `ps -ef | grep -Ev "grep|$0" | grep -c "$Service_Path" ` -gt 1 ]; then
		echo "$Service_Name有多个启动的进程"
		exit 1
	#若查找不到个进程。则设置psid=0 表示程序未运行
	else
		psid=0
	fi
}

#启动服务
start(){
	checkpid
	if [ $psid -ne 0 ];then
		echo "已经运行:  $Service_Name.jar (pid=$psid)"
	else
		echo  "$Time_Now [START]: 正在启动:  $Service_Name"
		echo  "$Time_Now [START]: 正在启动: $Service_Name"  >> $Shell_Log
		nohup $Java_Path $JAVA_OPTS -jar $Service_Path $JAR_OPTS > /dev/null 2>&1 &
		sleep 3
		checkpid
		if [ $psid -ne 0 ]; then
			echo "$Time_Now [START]: 启动完成: $Service_Name (pid:${psid})"
			echo $psid > $Service_Pid
			echo "$Time_Now [START]: 启动完成: $Service_Name (pid:${psid})" >> $Shell_Log
		else
			echo  "$Time_Now [START]: 启动失败: $Service_Name"
			echo  "$Time_Now [START]: 启动失败: $Service_Name" >> $Shell_Log
			exit 1
		fi
	fi
}

#停止服务
stop(){
	checkpid
	#psid不等于0时,服务运行,执行停止命令
	if [ $psid -ne 0 ];then
		echo "$Time_Now [STOP]: 正在停止: $Service_Name"
		echo "$Time_Now [STOP]: 正在停止: $Service_Name"  >> $Shell_Log
		kill -9 $psid
		sleep 3
		checkpid
		if [ $psid -eq 0 ]; then
			sleep 2
			echo  "$Time_Now [STOP]: 已经停止: $Service_Name [ok]"
			echo > $Service_Pid
			echo  "$Time_Now [STOP]: $Service_Name 已经停止"  >> $Shell_Log
		else
			echo  "$Time_Now [STOP]: 停止失败:  $Service_Name"
			echo  "$Time_Now [STOP]: $Service_Name 停止失败" >> $Shell_Log
			exit 1
		fi
	#psid=0时,服务未运行
	else
		echo "WARN: $Service_Name.jar 未运行"
	fi
}

#重启服务
restart(){
	stop
	start
}

#检查程序运行状态
status(){
	checkpid
	if [ $psid -ne 0 ]; then
		ps -ef|grep -Ev "grep|$0"|grep $Service_Path --color
	else
		echo "`basename $Service_Path` 未运行"
	fi
}

#查看帮助
help(){
	echo -e "\033[33;1m参数: $0
	########脚本启动相关命令
	start   SERVICE_NAME   启动服务
	stop    SERVICE_NAME   停止服务
	restart SERVICE_NAME   重启服务
	status  SERVICE_NAME   查看服务状态
	\033[0m"
}

#main
if  echo "$1"|grep -wE 'start|stop|restart|status|help' >/dev/null;then
	init
	$1
else
	help
fi
