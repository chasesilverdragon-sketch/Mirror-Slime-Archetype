# Publish Mirror Slime 1.0.0 on GitHub

These instructions are for the creator. **Nothing has been uploaded to GitHub yet.**

## 1. Create a repository

1. Sign in to GitHub and choose **New repository**.
2. A suggested name is **`Mirror-Slime-Archetype`**. You may choose another name.
3. Select **Public** if you want other players to access the pack.
4. Create the repository.

## 2. Upload the release files

1. Extract `Mirror_Slime_GitHub_v1.0.0.zip` on your computer.
2. In your new GitHub repository, use **Add file → Upload files**.
3. Upload the **contents** of the extracted folder, so that `README.md` and `Mirror_Slime_v1.0.0.ypk` are at the repository's top level. Also include `CHANGELOG.md`, `RELEASE_NOTES.md`, `PUBLISHING_GUIDE.md`, and `source/` if your browser upload supports folders. The playable `.ypk` and README are the essentials.
4. Commit the upload.

You can also use GitHub Desktop to publish the extracted directory if you prefer handling folders through a desktop interface.

## 3. Give players the correct MDPro4 link

Open `Mirror_Slime_v1.0.0.ypk` in the public repository. Click **Raw**, then copy the direct file URL.

For a repository named `Mirror-Slime-Archetype` on the `main` branch, it will look similar to:

`https://github.com/YOUR-USERNAME/Mirror-Slime-Archetype/raw/refs/heads/main/Mirror_Slime_v1.0.0.ypk`

Replace `YOUR-USERNAME` with your actual GitHub username. Use the link GitHub provides rather than guessing it. This **Raw** link is the one others should paste into **MDPro4 → Settings → Expansions → Download Custom Card Pack**. Do not paste the link to the repository's main page or a GitHub ZIP archive.

## 4. Optional: make a versioned GitHub Release

1. Open **Releases → Draft a new release** in the repository.
2. Create tag **`v1.0.0`**, and use title **`Mirror Slime 1.0.0 – First Public Playtest Release`**.
3. Copy the contents of `RELEASE_NOTES.md` into the release description.
4. Attach `Mirror_Slime_v1.0.0.ypk` as a downloadable release asset if desired, then publish the release.

The release page helps players find versions. For the MDPro4 in-game downloader, continue to share the **Raw link** to the `.ypk` stored in the repository.

## 5. Before sharing widely

- Open the Raw link in a browser to check that it downloads the `.ypk` directly.
- Try installing through MDPro4's downloader using that exact link.
- Confirm that card art and the included deck appear.
- Decide whether to add a separate open-source license if you want other developers to reuse code or artwork. None is included by default.
