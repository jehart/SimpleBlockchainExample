import os
import hashlib
import re
from typing import List, Tuple, Union

def sha256_hash(data: Union[bytes, str]) -> str:
    if isinstance(data, str):
        data = data.encode()
    return hashlib.sha256(data).hexdigest()


def extract_difficulty(block_contents):
    difficulty_pattern = re.compile(b'<difficulty>([0-9a-fA-F]+)</difficulty>')
    if isinstance(block_contents, str):
        block_contents = block_contents.encode()
    match = difficulty_pattern.search(block_contents)

    if match:
        return match.group(1).decode()
    else:
        return None


def extract_prior_block_info(block_content: str, is_first_block: bool) -> Tuple[str, str]:
    prior_block_hash_re = re.compile('<priorBlockHash>\s*<hash>([a-zA-Z0-9]+)</hash>\s*<file>(.*)<file/>\s*</priorBlockHash>')
    
    match = prior_block_hash_re.search(block_content)

    if match:
        prior_block_hash = match.group(1)
        prior_block_file = match.group(2) if not is_first_block else ''
        return prior_block_hash, prior_block_file

    return '', ''

def verify_block(block_path: str, previous_hash: str, is_first_block: bool) -> Tuple[bool, str, str]:
    with open(block_path, 'rb') as f:
        block_contents = f.read()

    prior_block_hash, prior_block_file = extract_prior_block_info(block_contents.decode(), is_first_block)
  
    if not is_first_block:
        if prior_block_hash != previous_hash:
            return False, None, None

 
    block_hash = sha256_hash(block_contents)
    difficulty = extract_difficulty(block_contents)

    if difficulty is None:
        return False, None, None

    target = int(difficulty, 16)

    if int(block_hash, 16) > target:
        return False, block_hash, difficulty
    return True, block_hash, difficulty


if __name__ == "__main__":
    previous_hash=""
    with open('chain', 'r') as f:
        chain_lines = f.readlines()

    for i, line in enumerate(chain_lines[1:]):
        block_hash = chain_lines[i].split()[0]
        block_path = line.split()[1]

        is_first_block = i == 0
        print("verifying block: ", block_path)
        is_valid, previous_hash, difficulty = verify_block(block_path, previous_hash, is_first_block)
        if not is_valid:
            print(f"Invalid block: {block_path}")
            break
