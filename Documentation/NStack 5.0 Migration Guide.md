# NStack 5.0 Migration Guide


Uses the updated [LocalizationManager](https://github.com/nodes-ios/TranslationManager/releases/tag/3.0-beta) (old TranslationManager) and [nstack-translations-generatorBundle 5.0](https://github.com/nodes-ios/nstack-localizations-generator/releases/tag/5.0)

**How to migrate**

1. Point to 5.0 in your Cartfile
    ```
    github "nstack-io/nstack-ios-sdk" ~> 5.0
    ```
2. Replace the `TranslationManager` framework from your embedded libraries with `LocalizationManager`
3. Update the Carthage copy-frameworks build phase to deal with `LocalizationManager` instead of `TranslationManager`
4. Replace all `import TranslationManager` with `import LocalizationManager`
5. Replace all `NStack.sharedInstance.translationsManager` with `NStack.sharedInstance.localizationManager`
6. Replace calls to `NStack.sharedInstance.translationsManager?.updateTranslations` with `NStack.sharedInstance.localizationManager?.updateLocalizations`
7. Update the way to setup NStack from
   
    ```swift
    private func setupNStack(with launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) {
        var nStackConfig = Configuration(plistName: nstackPlistName,
                                         environment: nstackEnvironment,
                                         translationsClass: Translations.self)
        nStackConfig.updateOptions = [.onDidBecomeActive]
        NStack.start(configuration: nStackConfig, launchOptions: launchOptions)
        NStack.sharedInstance.translationsManager?.updateTranslations()
    }
    ```

 to

   ```swift
     private func setupNStack(with launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) {
         var nStackConfig = Configuration(plistName: nstackPlistName,
                                         environment: nstackEnvironment,
                                         localizationClass: Localizations.self)
         nStackConfig.updateOptions = [.onDidBecomeActive]
         NStack.start(configuration: nStackConfig, launchOptions: launchOptions)
         NStack.sharedInstance.localizationManager?.updateLocalizations()
     }
    
   ```

8. Replace `TranslationManager.Language` with `LocalizationManager.DefaultLanguage`
9. Reference your translations with `lo.` instead of `tr.`. For example, `lo.default.ok`.