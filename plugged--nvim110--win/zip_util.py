import zipfile
import os
import getpass

def zip_folders(directory, password):
    """Zips all folders within the given directory, each with the provided password."""
    for item in os.listdir(directory):
        item_path = os.path.join(directory, item)
        if os.path.isdir(item_path):
            zip_filename = f"{item}.zip"
            zip_filepath = os.path.join(directory, zip_filename)
            try:
                with zipfile.ZipFile(zip_filepath, 'w', zipfile.ZIP_DEFLATED) as zf:
                    zf.setpassword(password.encode())
                    for root, _, files in os.walk(item_path):
                        for file in files:
                            file_path = os.path.join(root, file)
                            relative_path = os.path.relpath(file_path, item_path)
                            zf.write(file_path, relative_path)
                print(f"Successfully zipped folder '{item}' to '{zip_filename}'")
            except Exception as e:
                print(f"Error zipping folder '{item}': {e}")

def unzip_files(directory, password):
    """Unzips all .zip files within the given directory using the provided password."""
    for item in os.listdir(directory):
        if item.endswith(".zip"):
            zip_filepath = os.path.join(directory, item)
            extract_dir = item[:-4]  # Remove .zip extension to create extraction folder
            extract_path = os.path.join(directory, extract_dir)
            os.makedirs(extract_path, exist_ok=True)
            try:
                with zipfile.ZipFile(zip_filepath, 'r') as zf:
                    zf.setpassword(password.encode())
                    zf.extractall(extract_path)
                print(f"Successfully unzipped '{item}' to '{extract_dir}'")
            except RuntimeError:
                print(f"Error: Incorrect password for '{item}'")
            except Exception as e:
                print(f"Error unzipping '{item}': {e}")

if __name__ == "__main__":
    target_directory = input("Enter the directory containing folders to zip/unzip: ")
    action = input("Enter 'zip' to zip folders or 'unzip' to unzip files: ").lower()
    password = getpass.getpass("Enter the password for zipping/unzipping: ")

    if action == 'zip':
        zip_folders(target_directory, password)
    elif action == 'unzip':
        unzip_files(target_directory, password)
    else:
        print("Invalid action. Please enter 'zip' or 'unzip'.")