folder('Lesson38') {
    description('<div style="border-radius:10px; text-align: center; font-size:120%; padding:15px; background-color: powderblue;">Simple app CI/CD</div>')
}

multibranchPipelineJob('Lesson38/CI') {
    branchSources {
        branchSource {
            source {
                github {
                    // Specify the name of the GitHub Organization or GitHub User Account.
                    repoOwner('dum307')
                    // The repository to scan.
                    repository('TMS')
                    // Specify the HTTPS URL of the GitHub Organization / User Account and repository.
                    repositoryUrl('https://github.com/dum307/TMS.git')
                    configuredByUrl(true)
                    // Credentials used to scan branches and pull requests, check out sources and mark commit statuses.
                    credentialsId('github-http')
                    traits {
                        gitHubBranchDiscovery {
                            strategyId(3)
                        }
                        gitHubPullRequestDiscovery {
                            strategyId(1)
                        }
                        headWildcardFilter {
                            includes('main PR-* lesson38')
                            excludes('')
                        }
                        cloneOption {
                            extension {
                                // Perform shallow clone, so that git will not download the history of the project, saving time and disk space when you just want to access the latest version of a repository.
                                shallow(false)   
                                // Deselect this to perform a clone without tags, saving time and disk space when you just want to access what is specified by the refspec.
                                noTags(false)
                                // Specify a folder containing a repository that will be used by Git as a reference during clone operations.
                                reference('')
                                // Specify a timeout (in minutes) for clone and fetch operations.
                                timeout(10)
                            }
                        }
                    }
                }
            }
        }
    }
  	factory {
    	workflowBranchProjectFactory {
          	scriptPath('lesson38/Jenkinsfile-multi-ci')
        }
    }
  	properties {
        folderLibraries {
            libraries {
                libraryConfiguration {
                    name('general')
                    retriever {
                        modernSCM {
                            scm {
                                git {
                                    remote('https://github.com/dum307/TMS.git')
                                    credentialsId('github-http')
                                }
                                libraryPath('lesson38/libs/general')
                            }
                        }
                        // If checked, scripts may select a custom version of the library by appending @someversion in the @Library annotation.
                        allowVersionOverride(true)
                        // A default version of the library to load if a script does not select another.
                        defaultVersion('lesson38')
                    }
                }
                libraryConfiguration {
                    name('build')
                    retriever {
                        modernSCM {
                            scm {
                                git {
                                    remote('https://github.com/dum307/TMS.git')
                                    credentialsId('github-http')
                                }
                                libraryPath('lesson38/libs/build')
                            }
                        }
                        // If checked, scripts may select a custom version of the library by appending @someversion in the @Library annotation.
                        allowVersionOverride(true)
                        // A default version of the library to load if a script does not select another.
                        defaultVersion('lesson38')
                    }
                }
	        }
	    }
    }
    triggers {
        // The maximum amount of time since the last indexing that is allowed to elapse before an indexing is triggered.
        periodicFolderTrigger {
            interval('1m')
        }
    }
}

multibranchPipelineJob('Lesson38/CD') {
    branchSources {
        branchSource {
            source {
                github {
                    // Specify the name of the GitHub Organization or GitHub User Account.
                    repoOwner('dum307')
                    // The repository to scan.
                    repository('TMS')
                    // Specify the HTTPS URL of the GitHub Organization / User Account and repository.
                    repositoryUrl('https://github.com/dum307/TMS.git')
                    configuredByUrl(true)
                    // Credentials used to scan branches and pull requests, check out sources and mark commit statuses.
                    credentialsId('github-http')
                    traits {
                        gitHubBranchDiscovery {
                            strategyId(3)
                        }
                        gitHubPullRequestDiscovery {
                            strategyId(1)
                        }
                        headWildcardFilter {
                            includes('main PR-* lesson38')
                            excludes('')
                        }
                        cloneOption {
                            extension {
                                // Perform shallow clone, so that git will not download the history of the project, saving time and disk space when you just want to access the latest version of a repository.
                                shallow(false)   
                                // Deselect this to perform a clone without tags, saving time and disk space when you just want to access what is specified by the refspec.
                                noTags(false)
                                // Specify a folder containing a repository that will be used by Git as a reference during clone operations.
                                reference('')
                                // Specify a timeout (in minutes) for clone and fetch operations.
                                timeout(10)
                            }
                        }
                    }
                }
            }
        }
    }
  	factory {
    	workflowBranchProjectFactory {
          	scriptPath('lesson38/Jenkinsfile-multi-cd')
        }
    }
  	properties {
        folderLibraries {
            libraries {
                libraryConfiguration {
                    name('general')
                    retriever {
                        modernSCM {
                            scm {
                                git {
                                    remote('https://github.com/dum307/TMS.git')
                                    credentialsId('github-http')
                                }
                                libraryPath('lesson38/libs/general')
                            }
                        }
                        // If checked, scripts may select a custom version of the library by appending @someversion in the @Library annotation.
                        allowVersionOverride(true)
                        // A default version of the library to load if a script does not select another.
                        defaultVersion('lesson38')
                    }
                }
                libraryConfiguration {
                    name('deploy')
                    retriever {
                        modernSCM {
                            scm {
                                git {
                                    remote('https://github.com/dum307/TMS.git')
                                    credentialsId('github-http')
                                }
                                libraryPath('lesson38/libs/deploy')
                            }
                        }
                        // If checked, scripts may select a custom version of the library by appending @someversion in the @Library annotation.
                        allowVersionOverride(true)
                        // A default version of the library to load if a script does not select another.
                        defaultVersion('lesson38')
                    }
                }
	        }
	    }
    }
}