# Compiler
NVCC = nvcc

# Target executable
TARGET = app

# Source file
SRC = main.cu

# Compiler flags
NVCC_FLAGS = -O2 -std=c++17

# Build rule
all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(NVCC_FLAGS) $(SRC) -o $(TARGET)

# Clean build files
clean:
	rm -f $(TARGET)