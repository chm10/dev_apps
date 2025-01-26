#!/bin/bash

set -e

# Configuration
TEMPLATE_DIR="$HOME/.envgen_templates"
VSCODE_CMD="code"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_dependencies() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker not found. Please install Docker first.${NC}"
        exit 1
    fi

    if ! command -v code &> /dev/null; then
        echo -e "${YELLOW}Warning: VS Code command line tool not found. GUI opening might be needed.${NC}"
        VSCODE_CMD=""
    fi
}

validate_input() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Usage: $0 --name <project_name> --lang [c|cpp|python] [--parent-dir <path>]${NC}"
        exit 1
    fi

    case $2 in
        c|cpp|python) ;;
        *) echo -e "${RED}Error: Invalid language. Choose c/cpp/python${NC}"; exit 1 ;;
    esac
}

create_project() {
    local project_name=$1
    local lang=$2
    local parent_dir=${3:-$(pwd)}

    project_path="$parent_dir/$project_name"
    
    if [ -d "$project_path" ]; then
        echo -e "${RED}Error: Project directory already exists.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Creating new $lang project: $project_path${NC}"
    mkdir -p "$project_path/.devcontainer"

    # Copy templates
    cp "$TEMPLATE_DIR/$lang/Dockerfile" "$project_path/.devcontainer/"
    cp "$TEMPLATE_DIR/$lang/devcontainer.json" "$project_path/.devcontainer/"

    # Create language-specific files
    case $lang in
        c)
            touch "$project_path/main.c"
            ;;
        cpp)
            touch "$project_path/main.cpp"
            cat > "$project_path/CMakeLists.txt" << EOF
cmake_minimum_required(VERSION 3.10)
project($project_name)
add_executable(\${PROJECT_NAME} main.cpp)
EOF
            ;;
        python)
            touch "$project_path/main.py"
            ;;
    esac

    echo -e "${GREEN}Project created successfully!${NC}"
}

open_vscode() {
    if [ -n "$VSCODE_CMD" ]; then
        "$VSCODE_CMD" "$project_path"
    else
        echo -e "${YELLOW}Open VS Code manually at: $project_path${NC}"
    fi
}

# Main execution
install_templates() {
    echo -e "${GREEN}Installing templates...${NC}"
    mkdir -p "$TEMPLATE_DIR"
    cp -r "$(dirname "$0")/.envgen_templates/"* "$TEMPLATE_DIR/"
    echo -e "${GREEN}Templates installed to $TEMPLATE_DIR${NC}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            install_templates
            exit 0
            ;;
        --name|-n)
            PROJECT_NAME="$2"
            shift
            ;;
        --lang|-l)
            LANG="$2"
            shift
            ;;
        --parent-dir|-d)
            PARENT_DIR="$2"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Verify installation
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}Error: Templates not found. Run with --install first.${NC}"
    exit 1
fi

check_dependencies
validate_input "$PROJECT_NAME" "$LANG"
create_project "$PROJECT_NAME" "$LANG" "$PARENT_DIR"
open_vscode