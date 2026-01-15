# Nama binary output
TARGET = dumpet_linux

# Compiler
CC = gcc

# Flag Kompilasi
# -D__bswap... mengatasi masalah endian di Alpine/musl
# -Wno-error mencegah peringatan variabel menghentikan build
CFLAGS = -O2 -g3 -Wall --std=gnu99 \
         -I/usr/include/libxml2 \
         -D__bswap_32=__bswap32 \
         -D__bswap_16=__bswap16 \
         -Wno-unused-but-set-variable \
         -Wno-error

# Flag Linker untuk Static Binary
# Urutan library sangat penting dalam static linking
LDFLAGS = -Wl,--strip-all -Wl,--build-id=none -static
LIBS = -lpopt -lxml2 -lz -llzma -lm

# Daftar file objek
OBJS = dumpet.o applepart.o

# Rule Utama
all: $(TARGET)

# Rule untuk membuat binary
$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	@chmod +x $(TARGET)
	@echo "--------------------------------------"
	@echo "BUILD BERHASIL: $(TARGET)"
	@echo "--------------------------------------"
	@ls -l $(TARGET)
	@echo "--------------------------------------"
	@echo "VERIFIKASI STATIC LINKING:"
	@ldd $(TARGET) || echo "Status: Statically Linked (Tidak ada dependensi .so)"
	@echo "--------------------------------------"
	@file $(TARGET)
    
# Rule untuk kompilasi file .c menjadi .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Membersihkan hasil build
clean:
	rm -f $(OBJS) $(TARGET)

# Rule untuk menginstall dependensi di Alpine
deps:
	apk add popt-static libxml2-static zlib-static xz-static popt-dev libxml2-dev

.PHONY: all clean deps