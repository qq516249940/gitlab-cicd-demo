/* pipline语言格式 */
pipeline {
    /* 在stage阶段中指定执行节点 */
    agent none
    /* 通过pollSCM轮询监测版本改动 */
    triggers { pollSCM('*/1 * * * *') }
    /* 创建环境变量 */
    environment {
        USER = "xxx"
        MAIL = "xxx@xxx.com"
        PROJECT = "GAME OVER"
        PREPARATION = "None"
        BUILD = "None"
        DEPLOY = "None"
        TEST = "None"
    }
    /* 指定代码块 */
    stages {
        /* 指定主体阶段：拉取代码 */
        stage('Preparation') {
            /* 选择节点标签 */
            agent {
                label 'node1'
            }
            /* 指定DSL命令封装区域 */
            steps {
                /* 拉取代码 */
                git branch: 'xxxxxx', url: 'https://xxxx.git'
            }
            /* 校验条件：校验拉取代码 */
            post {
                /* 无论如何都执行 */
                always {
                    echo "The code pull action is completed"
                }
                /* 拉取失败执行 */
                failure {
                    /* 使用纯DSL语言编辑 */
                    script {
                        echo "Failed to execute code pull action!!!"
                        PREPARATION = "FAILED"
                    }
                }
                /* 拉取成功执行 */
                success {
                    /* 使用纯DSL语言编辑 */
                    script {
                        echo "Successfully execute code pull action!!!"
                        PREPARATION = "SUCCESS"
                    }
                }
            }
        }
        /* 指定主体阶段：打包代码 */
        stage('Build') {
            /* 选择节点标签 */
            agent {
                label 'node1'
            }
            /* 指定DSL命令封装区域 */
            steps {
                echo "gradle build will go here."
            }
            /* 校验条件：校验打包 */
            post {
                /* 无论如何都执行 */
                always {
                    echo "Build stage complete"
                }
                /* 打包失败执行 */
                failure {
                    /* 使用纯DSL语言编辑 */
                    script {
                        echo "Build failed!!!"
                        BUILD = "FAILED"
                    }
                }
                /* 打包成功执行 */
                success {
                    /* 使用纯DSL语言编辑 */
                    script {
                        echo "Build succeeded!!!"
                        BUILD = "SUCCESS"
                    }
                }
            }
        }
        /* 指定主体阶段：部署 */
        stage('Deploy') {
            /* 选择节点标签 */
            agent {
                label 'node1'
            }
            /* 指定DSL命令封装区域 */
            steps {
                echo "Deploy the project environment."
            }
        }
        /* 指定主体阶段：测试 */
        stage('Test') {
            /* 并发执行 */
            parallel {
                /* 指定主体阶段：测试组1 */
                stage ('set1') {
                    /* 选择节点标签：可选标签组 */
                    agent {
                        label 'node1'
                    }
                    /* 指定DSL命令封装区域 */
                    steps {
                        echo "Test project environment. node1"
                        echo "Test project environment. node2"
                        echo "Test project environment. node3"
                    }                    
                }
                /* 指定主体阶段：测试组2 */
                stage ('set2') {
                    /* 选择节点标签：可选标签组 */
                    agent {
                        label 'master'
                    }
                    /* 指定DSL命令封装区域 */
                    steps {
                        echo "Test project environment. master1"
                        echo "Test project environment. master2"
                        echo "Test project environment. master3"
                    }                    
                }                
            }

        }
    }
    /* 校验条件：校验整体发布流程 */
    post {
        /* 无论如何都执行 */
        always {
            echo "All executed"
        }
        /* 发布失败执行 */
        failure {
            /* 使用纯DSL语言编辑 */
            script {
                /* 发送邮件 */
                echo "Unfortunately failed!!!"
                mail to: "${MAIL}",
                subject: "项目:${PROJECT}发布失败",
                body: "Preparation=${PREPARATION}\nBUILD=${BUILD}\nDEPLOY=${DEPLOY}\nTEST=${TEST}"
            }
        }
        /* 发布成功执行 */
        success {
            /* 使用纯DSL语言编辑 */
            script {
                /* 发送邮件 */
                echo "Great success!!!"
                mail to: "${MAIL}",
                subject: "项目:${PROJECT}发布成功",
                body: "Preparation=${PREPARATION}\nBUILD=${BUILD}\nDEPLOY=${DEPLOY}\nTEST=${TEST}"
            }
        }
    }
}
