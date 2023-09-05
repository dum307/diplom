multibranchPipelineJob('CI-CD') {
    branchSources {
        branchSource {
            source {
                github {
                    // Specify the name of the GitHub Organization or GitHub User Account.
                    repoOwner('dum307')
                    // The repository to scan.
                    repository('diplom')
                    // Specify the HTTPS URL of the GitHub Organization / User Account and repository.
                    repositoryUrl('https://github.com/dum307/diplom.git')
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
                            includes('main PR-* dev')
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
          	scriptPath('kind/jenkins/jenkinsfile')
        }
    }
    triggers {
        // The maximum amount of time since the last indexing that is allowed to elapse before an indexing is triggered.
        periodicFolderTrigger {
            interval('1m')
        }
    }
}