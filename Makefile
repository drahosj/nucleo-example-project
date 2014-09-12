PROCESSOR=stm32f4
BOARD=nucleo

BSP_BOARD_NAME=STM32F4xx-Nucleo

DEVICE_ID=STM32F411xE

OUTPUT_FILE_NAME=nucleo-1.elf

#####
# Roots for include dirs and source code files of drivers
#####
PROJECT_ROOT=/home/jake/embedded-tools/projects/Nucleo-1

DRIVERS_ROOT=/opt/cross/stm32f4/Drivers

CMSIS_ROOT=$(DRIVERS_ROOT)/CMSIS
BSP_ROOT=$(DRIVERS_ROOT)/BSP
HAL_ROOT=$(DRIVERS_ROOT)/STM32F4xx_HAL_Driver

BUILD_DIR=$(PROJECT_ROOT)/build

#####
# Driver include dirs
#####

CMSIS_INC=$(CMSIS_ROOT)/Include
CMSIS_DEVICE_INC=$(CMSIS_ROOT)/Device/ST/STM32F4xx/Include
CMSIS_RTOS_INC=$(CMSIS_ROOT)/RTOS

BSP_INC=$(BSP_ROOT)/$(BSP_BOARD_NAME)

HAL_INC=$(HAL_ROOT)/Inc

#####
# Driver source dirs
#####

BSP_SRC=$(BSP_ROOT)/$(BSP_BOARD_NAME)

CMSIS_DEVICE_TEMPLATES=$(CMSIS_ROOT)/Device/ST/STM32F4xx/Source/Templates/gcc

HAL_SRC=$(HAL_ROOT)/Src

#####
# Driver source files to be included in compilation
#####

CMSIS_OBJECTS=startup_stm32f411xe.o

BSP_OBJECTS=stm32f4xx_nucleo.o

# Add the names of any source files in the HAL_SRC directories if you wish
# to use those HAL features

HAL_OBJECTS=stm32f4xx_hal.o stm32f4xx_hal_adc.o stm32f4xx_hal_cortex.o
HAL_OBJECTS+= stm32f4xx_hal_gpio.o stm32f4xx_hal_spi.o stm32f4xx_hal_dma.o
HAL_OBJECTS+= stm32f4xx_hal_rcc.o stm32f4xx_hal_adc_ex.o

#####
# Setup -I flags
#####

INCLUDE_DIRS=$(PROJECT_ROOT)/inc

 INCLUDE_DIRS+= $(CMSIS_INC)
 INCLUDE_DIRS+= $(CMSIS_DEVICE_INC)
# INCLUDE_DIRS+= $(CMSIS_RTOS_INC)
 INCLUDE_DIRS+= $(BSP_INC)
 INCLUDE_DIRS+= $(HAL_INC)

INCLUDE_FLAGS=$(foreach d, $(INCLUDE_DIRS), -I$d)

#####
# Setup additional source files to be compiled
#####

ADDITIONAL_SRC=
ADDITIONAL_BSP_SRC=$(foreach f, $(BSP_OBJECTS), $(BSP_SRC)/$f)
ADDITIONAL_HAL_SRC=$(foreach f, $(HAL_OBJECTS), $(HAL_SRC)/$f)

ADDITIONAL_SRC+= $(CMSIS_DEVICE_TEMPLATES)/$(CMSIS_OBJECTS)
ADDITIONAL_SRC+= $(ADDITIONAL_HAL_SRC)
ADDITIONAL_SRC+= $(ADDITIONAL_BSP_SRC)

#####
# Set compiler options
#####

TRIPLET=arm-none-eabi

CC=$(TRIPLET)-gcc
CXX=$(TRIPLET)-g++
LINK=$(TRIPLET)-ld
AR=$(TRIPLET)-ar
RANLIB=$(TRIPLET)-ranlib
AS=$(TRIPLET)-gcc -c

LINKER_SCRIPT=STM32F411RE_FLASH.ld
LINKER_SCRIPT=stm32f411re.ld

PREINCLUDES=

GCC_ARM_FLAGS=-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

CPPFLAGS=$(INCLUDE_FLAGS) $(foreach p, $(PREINCLUDES), -include $p) -D$(DEVICE_ID)

CFLAGS+= $(GCC_ARM_FLAGS) --specs=nosys.specs

MAKE+= -f $(PROJECT_ROOT)/Makefile

SUBMAKE_OUTPUT_OPTION=OUTPUT_OPTION="-o $(BUILD_DIR)/$$*.o"

#####
# Project source files
#####

PROJECT_OBJECTS=main.o stm32f4xx_it.o system_stm32f4xx.o

PROJECT_SRC_DIR=$(PROJECT_ROOT)/src

ALL_OBJECTS=$(PROJECT_OBJECTS) $(HAL_OBJECTS) $(BSP_OBJECTS) $(CMSIS_OBJECTS)


#############END CONFIGURATION###############

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $(BUILD_DIR)/$*.o -c $<
	
%.o: %.cc
	$(CXX) $(CPPFLAGS) $(CFLAGS) -o $(BUILD_DIR)/$*.o -c $<
	
%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CFLAGS) -o $(BUILD_DIR)/$*.o -c $<

%.o: %.s
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $(BUILD_DIR)/$*.o -c $<

default: build

link: $(ALL_OBJECTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) -T $(PROJECT_ROOT)/$(LINKER_SCRIPT) -o $(PROJECT_ROOT)/$(OUTPUT_FILE_NAME) $(ALL_OBJECTS)
	

additional-src-objects: Makefile
	cd $(BSP_SRC) && $(MAKE) $(BSP_OBJECTS)
	cd $(HAL_SRC) && $(MAKE) $(HAL_OBJECTS)
	cd $(CMSIS_DEVICE_TEMPLATES) && $(MAKE) $(CMSIS_OBJECTS)
	
build: Makefile additional-src-objects
	cd $(PROJECT_SRC_DIR) && $(MAKE) $(PROJECT_OBJECTS)
	cd $(BUILD_DIR) && $(MAKE) link
clean:
	cd $(BUILD_DIR) && rm -f *.o
	rm -f $(OUTPUT_FILE_NAME)


debug: $(OUTPUT_FILE_NAME)
	gdb $(OUTPUT_FILE_NAME) -ex 'target extended localhost:4242' -ex 'load'
