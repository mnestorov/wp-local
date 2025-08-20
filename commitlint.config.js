export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation only changes
        'style',    // Changes that don't affect code meaning
        'refactor', // Code change that neither fixes bug nor adds feature
        'perf',     // Performance improvement
        'test',     // Adding missing tests
        'chore',    // Changes to build process or auxiliary tools
        'revert',   // Reverts a previous commit
        'ci',       // CI configuration changes
        'build'     // Build system changes
      ]
    ],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
    'body-leading-blank': [2, 'always'],
    'body-max-line-length': [0, 'always', 100], // Disabled for release notes
    'footer-leading-blank': [2, 'always']
  }
};