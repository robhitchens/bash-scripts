# Journal manager feature plans

Plan document for feature ideas to add or expand functionality of journal manager.

## Feature ideas

* add config file 
    * add support for config file for locations of journal and templates
* add generic templating logic using awk or something and then make that configurable.
* refactor `spliceGoals` to use awk to replace the {goals} section in the header
* could add option to configuration to add encryption and decryption provided by user keys or passphrase for a seed.
* could action 'view' with options to view individual entry or concatenate entries into a view
    * This could be useful if combined with the encryption option.
* add action edit goals, as a shortcut to editing the currentGoals template.
    * Or alternative add `edit template {template-name}` sub command instead
* add action archive and setup config for archive location. archive action could accept an additional argument to specify which folder or entry to archive.
* could add action for archiving months of entries.
* could add action 'search' to run simple grep commands against journal entries + archives.
* could update logic in `manage()` with different types of journal templates and logic.
    * E.g. could add functionality to start new idea journal entries with fuzzy matching for entries.
* (sourced from comment in `manage()` function switch statement) should add option to new to create new files for different days. default to today.
* (sourced from comment in `manage()#overwrite` function switch statement) should probably prompt to confirm overwrite
