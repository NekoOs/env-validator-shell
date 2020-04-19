[Español](https://github.com/NekoOs/env-validator-shell/blob/master/readme/ES.md) · 
[Ingles](https://github.com/NekoOs/env-validator-shell/blob/master/README.md)

# Env Validator Shell <br><small>Validator for environment variables configuration file</small>

This is a script that allows you to validate the configuration of environment variables of a 
in deployment environments that do not allow the execution of project-specific languages,
if this is not your case, you can use libraries like: [Laravel Env Validator](https://github.com/mathiasgrimm/laravel-env-validator)
or [JS env-validator](https://www.npmjs.com/package/env-validator)
_________________________________        

How to install
--------------------------------

Review this project: <https://github.com/NekoOs/env-validator-shell>

```bash
wget https://raw.githubusercontent.com/NekoOs/env-validator-shell/master/src/env-validator.bash
```

How to start
--------------------------------

### Import library
You can call the library from each script

```bash
#!/usr/bin/env bash

source env-validator

# more sentences...
```
or register it in your `.bashrc` file for more convenient and widespread use.      

### Usage 

#### Validation from file
Define where the file you want to validate is located and the file containing the rules for validation 
see a [sample rule configuration file](https://github.com/NekoOs/env-validator-shell/blob/master/tests/.env.rules)  
```bash
validate_keys_with_rules_from_file /path/to/.env /path/to/.env.rules
```

### Example
imagine that you want to validate that your `.env` file contains some variables and even check the value of these.
Then you create an `.env.rules` file as follows:

```dotenv
APP_URL=required
MN_DB_PORT=required|integer
```

Then if the `.env` and `.env.rules` files are in the same directory from where you execute the function, 
then it would be enough:

```bash
validate_keys_with_rules_from_file
```

Otherwise, you can define the paths of the files as shown [above](#validation-from-file)

Available validation rules
--------------------------------

Below is a list of all available validation rules and their function:

- [Boolean](#boolean)  
- [Decimal](#decimal)
- [Integer](#integer)
- [Max](#maxvalue)
- [Min](#minvalue)
- [Numeric](#numeric)
- [Regular Expression](#regex)
- [Required](#required) 
- [Size](#sizevalue)  

#### [#](#boolean) boolean

The field under validation must be able to be cast as a boolean. Accepted input are `true`, `false`, `1`, `0`, `"1"`, and `"0"`.

#### [#](#decimal) decimal

The field under validation must be a decimal point.

#### [#](#integer) integer

The field under validation must be an integer.

> **Note**
>
> This validation rule does not verify that the input is of the "integer" variable type, only that the input is a string or numeric value that contains an integer.

#### [#](#maxvalue) max:*value

The field under validation must be less than or equal to a maximum *value*. Strings, numerics, arrays, and files are evaluated in the same fashion as the [`size`](#sizevalue) rule.

#### [#](#minvalue) min:*value

The field under validation must have a minimum *value*. Strings, numerics, arrays, and files are evaluated in the same fashion as the [`size`](#sizevalue) rule.

#### [#](#numeric) numeric

The field under validation must be numeric.

#### [#](#regexpattern) regex:*pattern*

The field under validation must match the given regular expression.

#### [#](#required) required

The field under validation must be present in the input data and not empty. A field is considered "empty" if one of the following conditions are true:
- The value is 'null'.
- The value is an empty string.

#### [#](#sizevalue) size:*value

The field under validation must have a size matching the given value. For string data, value corresponds to the number of characters. For numeric data, value corresponds to a given integer value (the attribute must also have the numeric or integer rule). 
