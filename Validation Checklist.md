# Validation Checklist

## Checklist

- [ ] Develop your extension in Visual Studio Code.
- [ ] The app.json file has mandatory settings that you must include. Here you can also read more about dependency syntax and multiple countries per a single app syntax.	Mandatory app.json settings
- [ ] Coding of Date must follow a specific format (no longer region specific)	Use the format yyyymmddD. For example, 20170825D.
- [ ] Remote services (including all Web services calls) can use either HTTP or HTTPS. However, HTTP calls are only possible by using the HttpRequest AL type.	Guidance on HTTP use
- [ ] Only JavaScript based Web client add-ins are supported. The zipping process is handled automatically by the compiler. Simply include the new AL controladdin type, JavaScript sources, and build the app.
- [ ] The .app file must be digitally signed.	Signing an APP Package File
- [ ] The user scenario document must contain detailed steps for all setup and user validation testing.	User Scenario Documentation
- [ ] Set the application areas that apply to your controls. Failure to do so will result in the control not appearing in Dynamics 365 Business Central.	Application Area guidance
- [ ] Permission set(s) must be created by your extension and when marked, should give the user all setup and usage abilities. A user must not be required to have SUPER permissions for setup and usage of your extension.	Exporting Permission Sets
- [ ] Managing Users and Permissions
- [ ] Before submitting for validation, ensure that you can publish/sync/install/uninstall/reinstall your extension. This must be done in a Dynamics 365 Business Central environment.	How to publish your app
- [ ] Thoroughly test your extension in a Dynamics 365 Business Central environment.	Testing Your Extension
- [ ] Do not use OnBeforeCompanyOpen or OnAfterCompanyOpen	Replacement Options
- [ ] Include the proper upgrade code allowing your app to successfully upgrade from version to version.	Upgrading Extensions
- [ ] Pages and code units that are designed to be exposed as Web services must not generate any UI that would cause an exception in the calling code.	Web Services Usage
- [ ] You must include all translations of countries your extension is supporting. The use of xliff is required.	Translating Your Extension, Countries and Translations Supported.
- [ ] You are required to prefix or suffix the Name property of your fields. This eliminates collision between apps.	Prefix/Suffix Guidelines
- [ ] You are required to include a Visual Studio Code test package with your extension. Ensure that you include as must code coverage as you can.	Testing the Advanced Sample Extension
- [ ] DataClassification is required for fields of all tables/table extensions. Property must be set to other than ToBeClassified.	Classifying Data
- [ ] You must use the Profile object to add profiles instead of inserting them into the Profiles table.	Profile Object
- [ ] Use addfirst and addlast for placing your actions on Business Central pages. This eliminates breaking your app due to Business Central core changes.
