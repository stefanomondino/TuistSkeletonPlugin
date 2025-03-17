import ProjectDescription
import ProjectDescriptionHelpers
import SkeletonPlugin

@MainActor let workspace = Workspace.workspace(projectName: Constants.projectName,
                                               modules: coreModules + bridgeModules + featureModules + appModules,
                                               testModules: testModules)
