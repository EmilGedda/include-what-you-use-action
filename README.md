# include what you use Github Action
Github Action for [include what you use](https://include-what-you-use.org/).
The action runs include what you use on a compilation database and then prints
missing and superfluous includes in header and source files.

The action currently only runs clang/LLVM 9 version of include what you use.

## Example usage
```yml
 - name: Run Include What You Use
   uses: EmilGedda/include-what-you-use-action@v1
   with:
     compilation-database-path: '.'
     output-format: 'iwyu' # Or 'clang'
     no-error: 'false'
```

### Inputs

| Input                     | Type              | Default value | Description                                                                     |
|---------------------------|-------------------|---------------|---------------------------------------------------------------------------------|
| compilation-database-path | Directory path    | '.'           | Relative path to directory containing the compilation database                  |
| output-format             | 'clang' or 'iwyu' | 'iwyu'        | Output format of the include suggestions                                        |
| no-error                  | 'true' or 'false' | 'false'       | If true, the action succeeds regardless if there are include suggestions or not |

### Outputs

No outputs currently.

