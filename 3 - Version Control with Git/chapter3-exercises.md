# TASK BREAK DOWN

## EXERCISE 1

- [x] Task 1: Clone the git repository to create a local copy
  - `git clone https://gitlab.com/twn-devops-bootcamp/latest/03-git/git-exercises.git`
- [x] Task 2: Add a new remote for your own GitHub repository
  - `git remote add origin https://github.com/karanthakakr04/devops-bootcamp-exercises.git`
- [x] Task 3: Push the local repository to your GitHub remote
  - `git push origin main`

## EXERCISE 2

- [x] Task 1: Remove tracked build folders from git cache
  - `git rm -r --cached`
- [x] Task 2: Create .gitignore file
- [x] Task 3: Add following to .gitignore:
  - .idea/
  - .DS_Store
  - out/
  - build/
- [x] Task 4: Commit .gitignore file
  - `git add .`
  - `git commit -m "Add .gitignore file"`
- [x] Task 5: Push commit to remote repository
  - `git push origin main`

## EXERCISE 3

- [x] Task 1: Create feature branch
  - `git switch -c feature/branch`
- [x] Task 2: Upgrade logstash-logback-encoder version to 7.3
- [x] Task 3: Add new image to index.html
- [x] Task 4: Review changes
  - `git diff`
- [x] Task 5: Commit changes
  - `git add .`
  - `git commit -m "Upgrade libs and add new image"`
- [x] Task 6: Push feature branch to remote
  - `git push origin feature/branch`

## EXERCISE 4

- [x] Task 1: Create bugfix branch
  - `git switch -c bugfix/branch`
- [x] Task 2: Fix spelling error in Application.java
- [x] Task 3: Review changes
  - `git diff`
- [x] Task 4: Commit changes
  - `git add Application.java`
  - `git commit -m "Fix typo in Application.java"`
- [x] Task 5: Push bugfix branch to remote
  - `git push origin bugfix/branch`

## EXERCISE 5

- [x] Task 1: Create a pull request in GitHub UI
  - Source branch: `feature/branch`
  - Target branch: `main`
- [x] Task 2: Add description and details for the pull request
- [x] Task 3: Request a code review from teammates
- [x] Task 4: Teammates approve the pull request after testing
- [x] Task 5: Merge the feature branch into master via the pull request
- [x] Task 6: Delete the merged feature branch

## EXERCISE 6

- [x] Task 1: On bugfix branch, update logger lib version to 7.2
- [x] Task 2: Commit change to bugfix branch
- [x] Task 3: Merge master into bugfix
  - `git merge main`
- [x] Task 4: Resolve merge conflict
  - Accept current change in bugfix branch
  - Remove duplicate code from master
- [x] Task 5: Commit merged changes
  - `git add .`
  - `git commit -m "Merge master and resolve conflict"`
- [x] Task 6: Push merged bugfix branch to remote
  - `git push origin bugfix/branch`

## EXERCISE 7

- [x] Task 1: Fix typo in index.html, commit
- [x] Task 2: Change image url in index.html, commit
- [x] Task 3: Push both commits to remote branch
- [x] Task 4: Revert last image url commit
  - `git revert HEAD~1`
- [x] Task 5: Commit the revert
  - `git commit -m "Revert image url change"`
- [x] Task 6: Push reverted commit to remote
  - `git push origin bugfix/branch`

## EXERCISE 8

- [x] Task 1: Update Bruno's role in text
- [x] Task 2: Commit change locally
  - `git add .`
  - `git commit -m "Update Bruno's role"`
- [x] Task 3: Do NOT push commit to remote
- [x] Task 4: Reset last commit
  - `git reset HEAD~1`

## EXERCISE 9

- [x] Task 1: Switch to master branch
  - `git switch main`
- [x] Task 2: Pull latest changes
  - `git pull origin main`
- [x] Task 3: Merge bugfix branch into master
  - `git merge bugfix/branch`
- [x] Task 4: Resolve any merge conflicts
- [x] Task 5: Commit merged master
  - `git commit -m "Merge bugfix into main"`
- [x] Task 6: Push merged master to remote
  - `git push origin main`

## EXERCISE 10

- [x] Task 1: Delete feature branch locally
  - `git branch -d feature/branch`
- [x] Task 2: Delete feature branch remotely
  - `git push origin --delete feature/branch`
- [x] Task 3: Delete bugfix branch locally
  - `git branch -d bugfix/branch`
- [x] Task 4: Delete bugfix branch remotely
  - `git push origin --delete bugfix/branch`
