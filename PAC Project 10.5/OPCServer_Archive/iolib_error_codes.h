/*-----------------------------------------------------------------------------

  File:     iolib_error_codes.h

  Desc:     Header for analog I/O commands

  Notes:    This file is read by a limited parser in iolib_error.
            
            The parser expects explicit O22_ s, nested O22s are not permitted
            between the __START and __END sections.

            The lists MUST be sorted from higher values to lower values. If a
            sort error is wrong, the search may find the wrong matching value
            (or outright fail).

            Block comments must start from column 0 and end on column 0.

            No duplicate numeric codes!
            (NOTE: Product and error codes are treated separately)

            There is a maximum length of each line, 1023 characters. There is
            no length maximum for each message. The definition label must be
            less than 64 characters.

  About:    Error codes are reported as a concatenation of three elements:

         1) Severity: Indicates if the error reported is a warning (zero) or an
            error (one). Severity is implied by the sign of the error code and
            should not be manipulated into an error code or a product code.

            The control engine uses three severity levels and a user bit:
              [User bit can be set in addition to other levels]
            - User:           (1<<1)
              [The next 3 levels are mutually exclusive]
            - Informational:  (1<<2)  
            - Warning:        (1<<3)
            - Error:          (1<<4)

         2) Product code: A POSITIVE value that suggests which layer / hardware
            reported the error. There may be up to 32767 unique product codes.

         3) Error: Although there are 65536 possible error codes, (-32768 to
            +32767), failure should always be indicated with a NEGATIVE value.
            If there is no error, and no extra result info needs to be passed,
            O22_RESULT_SUCCESS, (defined as zero), should be passed. A positive
            non-zero value should only be used to pass data resulting from a
            successful transaction.

  AppNote:  Instead of looking for a particular value, applications should look
            for a negative value to check for an error condition.

-----------------------------------------------------------------------------*/


#ifndef __IOLIB_ERROR_CODES_HDR__
#define __IOLIB_ERROR_CODES_HDR__

// stuff for iolib_error and maybe for a client
#define IOLIB_ERROR_SEVERITY_MASK                       0x80000000
#define IOLIB_ERROR_PRODUCT_MASK                        0x7fff0000
#define IOLIB_ERROR_CATEGORY_MASK                       0x000f0000
#define IOLIB_ERROR_ERROR_MASK                          0x8000ffff
#define IOLIB_ERROR_ERROR_CODE_MASK                     0x0000ffff

// macros
#define IOLIB_ERROR(product,error)                      ((product << 16) | (error & IOLIB_ERROR_ERROR_MASK))
#define IOLIB_ERROR_PRODUCT_CODE(errorcode)             ((errorcode & IOLIB_ERROR_PRODUCT_MASK) >> 16)
#define IOLIB_ERROR_CATEGORY_CODE(errorcode)            ((errorcode & IOLIB_ERROR_CATEGORY_MASK) >> 16)
#define IOLIB_ERROR_ERROR_CODE(errorcode)               (errorcode & IOLIB_ERROR_ERROR_MASK)
#define IOLIB_ERROR_SEVERITY_FLAG(errorcode)            (errorcode & IOLIB_ERROR_SEVERITY_MASK)

// typedef to standardize all this
typedef int IOLIB_INT_ERROR_CODE;

// typedefs that establish error code categories, lowest 4 bits of product entry (next group)
#define O22_CATEGORY_DEFAULT                            0       // Unknown category library
#define O22_CATEGORY_STREAM                             1       // Stream category library
#define O22_CATEGORY_PROTOCOL                           2       // Protocol category library
#define O22_CATEGORY_SUPPORT                            3       // Support category library
#define O22_CATEGORY_DEVICE                             4       // Hardware response category
#define O22_CATEGORY_SYSTEM                             5       // Operating System category

// __START_PRODUCT_ENTRIES__
#define O22_PRODUCT_SOCKET_MESSAGE                      421     // OS Generated Socket Error Code
#define O22_PRODUCT_IOLIB_ARCNET                        401     // Iolib Arcnet 
#define O22_PRODUCT_IOLIB_PING                          387     // Iolib Ping Library
#define O22_PRODUCT_UIO_KERNEL_DOWNLOAD                 370     // Iolib UIO Kernel Download Library
#define O22_PRODUCT_HANDLE_MANAGER                      355     // Iolib Handle Manager Module
#define O22_PRODUCT_ENGINE_TABLE                        338     // Iolib Engine Object Table Module
#define O22_PRODUCT_OPTOMUX_BRAIN                       324     // Optomux Brain
#define O22_PRODUCT_1394                                306     // EIO/UIO 1394 Protocol Library
#define O22_PRODUCT_OPTOMUX                             290     // Optomux Protocol Library
#define O22_PRODUCT_ENGINE                              276     // Engine Host Task
#define O22_PRODUCT_IOLIB_TCPIP_CONFIG                  259     // Iolib System IP Config Library
#define O22_PRODUCT_IOLIB_VERSION                       243     // Iolib Version Library
#define O22_PRODUCT_IOLIB_SERIAL                        225     // Iolib Raw Serial Library
#define O22_PRODUCT_IOLIB_IP                            209     // Iolib Raw IP Library
#define O22_PRODUCT_IOLIB_CONTROLLER_CORE               195     // Controller Protocol Library
#define O22_PRODUCT_CONTROLLER                          179     // Controller Host Task
#define O22_PRODUCT_IOLIB_UTILITIES                     163     // Iolib Utilities Library
#define O22_PRODUCT_IOLIB_OPTOMUX                       146     // Iolib Optomux Protocol Library
#define O22_PRODUCT_IOLIB_ERROR                         131     // Iolib Error Reporting Library
#define O22_PRODUCT_IOLIB_CONTINFO                      115     // Iolib Engine Information Library
#define O22_PRODUCT_IOLIB_STREAMS                       97      // Iolib Streams Library
#define O22_PRODUCT_IOLIB_IPCONFIG                      83      // Iolib IP Configure Library
#define O22_PRODUCT_IOLIB_1394_DISCOVER                 67      // Iolib Brain Discovery Library
#define O22_PRODUCT_IOLIB_1394_LOADER                   50      // Iolib 1394 Kernel Loader Library
#define O22_PRODUCT_IOLIB_1394_CORE                     34      // Iolib 1394 Protocol Library
#define O22_PRODUCT_IOLIB_ENGINE_CORE                   18      // Iolib Engine Protocol Library
#define O22_PRODUCT_DEFAULT                             0       // Unknown Product Code
// __END_PRODUCT_ENTRIES__

// Highest error code value
#define O22_RESULT_MAX_VALUE                            O22_RESULT_RELEASELC_WRONG_DEVICE

// __START_ERROR_CODES__
#define O22_RESULT_RELEASELC_WRONG_DEVICE               25938   // Unexpected response. Verify the device is an Opto control engine, and is using the correct port (default is 22001).
#define O22_RESULT_WRONG_TYPE_OR_PORT                   3393    // Unexpected response. Verify the device is an Opto control engine, and is using the correct port (default is 22001).

#define O22_RESULT_TIMEOUT_WARNING                      3       // Operation reports a warning timeout. May be due to waiting for an event that hasn't occurred.
#define O22_RESULT_SCANNER_OVERRUN                      2       // Scanner Overrun. Reevaluate the amount of data scanned per cycle.

#define O22_RESULT_SUCCESS                              0       // Operation performed successfully.
#define O22_RESULT_UNDEFINED_COMMAND                    -1      // Undefined command.
#define O22_RESULT_DVF_MISMATCH                         -2      // Checksum or CRC mismatch.
#define O22_RESULT_INVALID_LENGTH                       -3      // Buffer overrun or invalid length error.
#define O22_RESULT_PUC_EXPECTED                         -4      // Device has powered up. ('Powerup clear expected' message received.)
#define O22_RESULT_OPERATION_FAILED                     -5      // Operation failed.
#define O22_RESULT_INVALID_DATA_FIELD                   -6      // Data field error.
#define O22_RESULT_WATCHDOG_TIMEOUT                     -7      // Watchdog timeout has occurred.
#define O22_RESULT_INVALID_DATA                         -8      // Invalid data.
#define O22_RESULT_TIMEOUT                              -9      // Timeout. No response from device. Check hardware connection, address, power, and jumpers.
#define O22_RESULT_BAD_PORT_NUMBER                      -10     // Invalid port number.
#define O22_RESULT_SEND_PROBLEM                         -11     // Could not send data.
#define O22_RESULT_INVALID_INDEX                        -12     // Invalid table index.
#define O22_RESULT_OVERFLOW                             -13     // Overflow error.
#define O22_RESULT_NOT_A_NUMBER                         -14     // Invalid number.
#define O22_RESULT_DIVIDE_BY_ZERO                       -15     // Cannot divide by zero.
#define O22_RESULT_BUS_ERROR                            -16     // Bus error.
#define O22_RESULT_PORT_ALREADY_LOCKED                  -17     // Port or object is already locked.
#define O22_RESULT_NOT_CONFIGURED                       -18     // I/O Unit not configured.
#define O22_RESULT_INVALID_HOLD_READ                    -19     // Reading hold for wrong reaction type.
#define O22_RESULT_RESOURCE_BUSY                        -20     // Device busy. May be in use by another user or another application.
#define O22_RESULT_HOST_NEEDED_RELOCK                   -21     // Had to relock host port in 'QUIT'.
#define O22_RESULT_INVALID_COMMAND_FOR_BOARD            -22     // Command not valid on specified I/O Unit.
#define O22_RESULT_DEST_STRING_TOO_SHORT                -23     // Destination string too short.
#define O22_RESULT_UNKNOWN_DEVICE_COMMAND               -24     // Device does not understand command.
#define O22_RESULT_PORT_NOT_LOCKED                      -25     // Port or object is not locked.
#define O22_RESULT_UNKNOWN_RESPONSE                     -26     // Unknown response from device.
#define O22_RESULT_HI_LO_LIMITS_SWAPPED                 -27     // Invalid limit error. High/Low values may be reversed.
#define O22_RESULT_OBJECT_NOT_FOUND                     -28     // Object not found.
#define O22_RESULT_WRONG_OBJECT_TYPE                    -29     // Wrong object type. Most likely caused by moving a pointer table element to a pointer of the wrong type.
#define O22_RESULT_POINTER_NOT_INITIALIZED              -30     // Pointer was not initialized.
#define O22_RESULT_LOCAL_OBJECT_UNUSABLE                -31     // Cannot store local subroutine object into a pointer table parameter.
#define O22_RESULT_DEVICE_NOT_READY                     -32     // Device has not been initialized.
#define O22_RESULT_CANNOT_CLEAR_PORT                    -33     // Unable to clear all characters from port.
#define O22_RESULT_INVALID_IO_COMMAND                   -34     // Invalid I/O command or invalid memory location. 
#define O22_RESULT_POINT_TYPE_MISMATCH                  -35     // I/O point mismatch: a configured channel does not match the type found on the I/O Unit or is a channel type not supported by the I/O Unit's firmware. Check www.opto22.com for firmware updates.
#define O22_RESULT_FEATURE_NOT_IMPLEMENTED              -36     // Invalid command or feature not implemented. 
#define O22_RESULT_PORT_LOCK_TIMEOUT                    -37     // Timeout on lock.
#define O22_RESULT_SEND_TIMEOUT                         -38     // Timeout on send.
#define O22_RESULT_RECEIVE_TIMEOUT                      -39     // Timeout on receive.
#define O22_RESULT_NOT_ENOUGH_DATA_RETURNED             -40     // Not enough data returned. (Received less than expected.)
#define O22_RESULT_INVALID_RETURN_DATA                  -41     // Invalid return data.
#define O22_RESULT_INVALID_LIMIT                        -42     // Invalid limit (on string index, task state, priority, etc.).
#define O22_RESULT_NACK_RECEIVED                        -43     // Received a NACK.
#define O22_RESULT_STRING_TOO_SHORT                     -44     // String too short.
#define O22_RESULT_EMPTY_STRING                         -45     // Null string.
#define O22_RESULT_INVALID_STRING_DATA                  -46     // Invalid string.
#define O22_RESULT_ALREADY_OPEN                         -47     // Open failed--handle has already been opened. 
#define O22_RESULT_NO_SUCH_DEVICE                       -48     // No such device available.
#define O22_RESULT_NO_MORE_STREAMS                      -49     // No more connections are available. Maximum number of connections already in use.
#define O22_RESULT_OPEN_STREAM_TIMEOUT                  -50     // Open connection timeout. Could not establish connection within the timeout period.
#define O22_RESULT_CLOSE_STREAM_TIMEOUT                 -51     // Close connection timeout. Could not close connection within timeout period.
#define O22_RESULT_STREAM_NOT_OPEN                      -52     // Invalid connection -- not opened.
#define O22_RESULT_INVALID_STREAM_HANDLE                -53     // Connection number not valid.
#define O22_RESULT_NO_STREAM_SELECTED                   -54     // No active connection for specified port.
#define O22_RESULT_WRONG_CONTROLLER_TYPE                -55     // Control engine type is invalid for the function requested.
#define O22_RESULT_INVALID_ADDRESS                      -56     // Invalid address.
#define O22_RESULT_STRING_NOT_FOUND                     -57     // String not found.
#define O22_RESULT_CHARACTER_NOT_FOUND                  -58     // No data received.
#define O22_RESULT_RECEIVE_PROBLEM                      -59     // Could not receive data.
#define O22_RESULT_EMPTY_STACK                          -60     // Empty stack error. Control engine attempted to perform an operation that expected data on the control engine stack.
#define O22_RESULT_DICTIONARY_FULL                      -61     // Dictionary full error; no more RAM available. Try clearing and re-downloading the strategy using PAC Control or PAC Terminal, if appropriate.
#define O22_RESULT_STACK_FULL                           -62     // Stack full error. Control engine stack has grown too big.
#define O22_RESULT_COMPILE_ONLY                         -63     // Compile-only error. A command or 'word' was encountered that should only be used when compiling commands or 'words'.
#define O22_RESULT_EXECUTE_ONLY_ERROR                   -64     // Execute-only error. A command or 'word' was encountered that cannot be used when compiling.
#define O22_RESULT_DEFINITION_NOT_FINISHED              -65     // Definition not finished.
#define O22_RESULT_IN_PROTECTED_DICTIONARY              -66     // Requested item in protected dictionary
#define O22_RESULT_OUT_OF_MEMORY                        -67     // Out of memory. To minimize the size of your strategy, reduce the number and size of variables (especially tables). You can also shrink your strategy by using subroutines to perform common tasks.
#define O22_RESULT_CONDITIONALS_MISMATCH                -68     // Conditionals do not match.
#define O22_RESULT_NULL_OBJECT_ERROR                    -69     // Invalid parameter (null pointer) passed to command.
#define O22_RESULT_NOT_ENOUGH_DATA_SUPPLIED             -70     // Not enough data supplied.
#define O22_RESULT_OUT_OF_PERSISTENT_MEMORY             -71     // Out of non-volatile memory. If applicable, check length of persistent and initialize-on-download tables.
#define O22_RESULT_NESTING_TOO_DEEP                     -72     // Too many nested subroutines (one calls another calls another).
#define O22_RESULT_BAD_PARAMS                           -73     // Invalid subroutine parameters. Too many parameters passed or incorrect subroutine.
#define O22_RESULT_INVALID_FILENAME                     -74     // Invalid filename. Check length and special characters.
#define O22_RESULT_OUT_OF_FILE_HANDLES                  -75     // No remaining file handles.
#define O22_RESULT_AT_END_OF_FILE                       -76     // End of file error. Attempted to access data past the end of the file.
#define O22_RESULT_HOST_START_FAILED                    -77     // Host task failed. Possible cause: specified host port is already in use, or host attempted to load a non-existent strategy file.
#define O22_RESULT_FTP_NO_DEST                          -78     // No destination given (the name of the file ftp on the remote server).
#define O22_RESULT_IOUNIT_TYPE_MISMATCH                 -79     // I/O Unit mismatch: the configured I/O Unit type does not match the unit type found.	
#define O22_RESULT_REBOOT_FOR_REGISTRY_CHANGES          -80     // Reboot for changes to the Windows Registry to take effect.
#define O22_RESULT_MEM_MAP_WRITE_ERROR                  -81     // Error writing to the memory map.
#define O22_RESULT_MEM_MAP_READ_ERROR                   -82     // Error reading from the memory map.
#define O22_RESULT_INVALID_SEVERITY                     -83     // Invalid severity. Valid values: Info = 4 , Warn = 8, Error = 16
#define O22_RESULT_NEW_VAR_AFTER_LOCAL_ALLOC            -84     // Can't reallocate memory while it is in use by a subroutine.
#define O22_RESULT_FAIL_CREATE_TX_SEMA                  -85     // TX Semaphore creation error.
#define O22_RESULT_FAIL_CREATE_RX_SEMA                  -86     // RX Semaphore creation error.
#define O22_RESULT_OPEN_FAILED                          -87     // Open error.
#define O22_RESULT_FAIL_CREATE_RX_TASK                  -88     // RX task creation error.
#define O22_RESULT_FAIL_CREATE_RX_HISR                  -89     // RX HISR creation error.
#define O22_RESULT_FAIL_CREATE_TX_HISR                  -90     // TX HISR creation error.
#define O22_RESULT_FAIL_REGISTER_LISR                   -91     // LISR registration error.
#define O22_RESULT_FAIL_UART_OPEN                       -92     // Open UART error.
#define O22_RESULT_DISABLED                             -93     // I/O Unit not enabled. Previous communication failure may have disabled the unit automatically. Reenable it and try again.
#define O22_RESULT_INVALID_EVENT_ENTRY                  -94     // Trying to enable NULL event, or bad event command.
#define O22_RESULT_STACK_NOT_EMPTY                      -95     // Data stack is not empty
#define O22_RESULT_STACK_CRITICAL                       -96     // Data stack critically full; stopping task
#define O22_RESULT_STACK_UNDERFLOW                      -97     // Too many items popped from data stack
#define O22_RESULT_BOOT_ID_MISMATCH                     -98     // Boot ID from I/O unit doesn't match the controller's stored value; performing full config
#define O22_RESULT_INVALID_CONTROLLER_NAME_LENGTH       -100    // Invalid length for control engine name. Must be 1 to 31 characters.
#define O22_RESULT_INVALID_CHAR_IN_CONTROLLER_NAME      -101    // Invalid character in control engine name. Valid characters are letters, numbers, spaces, and most other characters except colons and square brackets. Spaces cannot be used as first or last characters.
#define O22_RESULT_INVALID_END_CHAR_IN_CONTROLLER_NAME  -102    // First and last characters in control engine name cannot be spaces.
#define O22_RESULT_WRONG_TASK                           -103    // Could not unlock. The task attempting to do the unlock does not match the task that currently has the lock.

#define O22_RESULT_BAD_KEY_DATA                         -104    // Bad key data, (data missing, bad length, or corrrupt).
#define O22_RESULT_DECRYPTION_FAILURE                   -105    // Decryption failure
#define O22_RESULT_ENCRYPTION_FAILURE                   -106    // Encryption failure
// This error is returned by the board driver, to let the caller know the board
// is offline and no communications was attempted. This is different from a -93
// which means a send / receive was attempted but failed beacuse the board was
// disabled.
#define O22_RESULT_NOT_ENABLED                          -107    // The board is offline or disabled; no send / receive attempt made
#define O22_RESULT_INTERRUPTED                          -108    // An operation was interrupted
#define O22_RESULT_READ_ONLY                            -109    // Performed a write to read-only memory or file.
#define O22_RESULT_NO_MEDIA                             -110    // The microSD card is missing.
#define O22_RESULT_NOT_SUPPORTED_BY_HARDWARE            -111    // The hardware doesn't support this feature.
#define O22_RESULT_NVRAM_INVALID                        -112    // NVRAM does not match the current strategy; it may have been changed by a strategy from uSD, or the battery may need to be replaced.

#define O22_RESULT_UNHANDLED_EXCEPTION                  -113    // An unhandled exception was encountered.
#define O22_RESULT_OPERATION_ABORTED                    -114    // The operation was aborted.
#define O22_RESULT_SEARCH_FAILED                        -115    // Search failed.
#define O22_RESULT_ENDLESS_LOOP                         -116    // Operation would result in an endless loop.

#define O22_RESULT_INVALID_IOUNIT_NAME_LENGTH           -117    // Invalid length for I/O Unit name. Must be 1 to 50 characters.
#define O22_RESULT_INVALID_CHAR_IN_IOUNIT_NAME          -118    // Invalid character in I/O Unit name. Valid characters are letters, numbers, and underscore. The first letter must be alphabetic.
#define O22_RESULT_INVALID_FIRST_CHAR_IN_IOUNIT_NAME    -119    // The first character in an I/O Unit name must be alphabetic.
#define O22_RESULT_INVALID_IOUNIT_DESC_LENGTH           -120    // Invalid length for I/O Unit description. Must be 1 to 127 characters.
#define O22_RESULT_INVALID_IOUNIT_ADDR_LENGTH           -121    // Invalid length for I/O Unit Primary Address. Must be 1 to 255 characters.
#define O22_RESULT_INVALID_IOUNIT_ADDR_2_LENGTH         -122    // Invalid length for I/O Unit Secondary Address. Must be 1 to 255 characters.
#define O22_RESULT_INVALID_IOUNIT_HOSTNAME_ONECHAR      -123    // Hostname can not be one character.
#define O22_RESULT_INVALID_IOUNIT_HOSTNAME_TOOBIG       -124    // Hostname must be no more than 255 characters.
#define O22_RESULT_INVALID_IOUNIT_HOSTNAME_BADCHAR      -125    // Invalid character in Hostname.
#define O22_RESULT_INVALID_IOUNIT_HOSTNAME_LASTCHAR     -126    // Last character in Host Name must not be -.
#define O22_RESULT_INVALID_CHANNEL_NAME_LENGTH          -127    // Invalid length for Channel name. Must be 1 to 50 characters.
#define O22_RESULT_INVALID_CHAR_IN_CHANNEL_NAME         -128    // Invalid character in Channel name. Valid characters are letters, numbers, and underscore. The first letter must be alphabetic.
#define O22_RESULT_INVALID_FIRST_CHAR_IN_CHANNEL_NAME   -129    // The first character in a Channel name must be alphabetic.
#define O22_RESULT_INVALID_CHANNEL_DESC_LENGTH          -130    // Invalid length for Channel description. Must be 1 to 127 characters.
#define O22_RESULT_INVALID_CHANNEL_UNITS_LENGTH         -131    // Invalid length for Analog Channel units string. Must be 1 to 50 characters.
#define O22_RESULT_INVALID_CHART_NAME_LENGTH            -132    // Invalid length for Chart name. Must be 1 to 50 characters.
#define O22_RESULT_INVALID_CHAR_IN_CHART_NAME           -133    // Invalid character in Chart name. Valid characters are letters, numbers, and underscore. The first letter must be alphabetic.
#define O22_RESULT_INVALID_FIRST_CHAR_IN_CHART_NAME     -134    // The first character in a Chart name must be alphabetic.
#define O22_RESULT_INVALID_CHART_DESC_LENGTH            -135    // Invalid length for Chart description. Must be 1 to 127 characters.
#define O22_RESULT_INVALID_VARIABLE_NAME_LENGTH         -136    // Invalid length for Variable name. Must be 1 to 50 characters.
#define O22_RESULT_INVALID_CHAR_IN_VARIABLE_NAME        -137    // Invalid character in Variable name. Valid characters are letters, numbers, and underscore. The first letter must be alphabetic.
#define O22_RESULT_INVALID_FIRST_CHAR_IN_VARIABLE_NAME  -138    // The first character in a Variable name must be alphabetic.
#define O22_RESULT_INVALID_VARIABLE_DESC_LENGTH         -139    // Invalid length for Variable description. Must be 1 to 127 characters.
#define O22_RESULT_INVALID_VARIABLE_INIT_LENGTH         -140    // Invalid length for Variable initial value. Must be 1 to 1024 characters.
#define O22_RESULT_INVALID_NUMVAR_INIT_LENGTH           -141    // Invalid length for Numeric Variable initial value. Must be 1 to 29 characters.
#define O22_RESULT_INVALID_TABLE_NAME_LENGTH            -142    // Invalid length for Table name. Must be 1 to 50 characters.
#define O22_RESULT_INVALID_CHAR_IN_TABLE_NAME           -143    // Invalid character in Table name. Valid characters are letters, numbers, and underscore. The first letter must be alphabetic.
#define O22_RESULT_INVALID_FIRST_CHAR_IN_TABLE_NAME     -144    // The first character in a Table name must be alphabetic.
#define O22_RESULT_INVALID_TABLE_DESC_LENGTH            -145    // Invalid length for Table description. Must be 1 to 127 characters.
#define O22_RESULT_INVALID_TABLE_INIT_LENGTH            -146    // Invalid length for Table initial value. Must be 1 to 1024 characters.
#define O22_RESULT_INVALID_NUMTABLE_INIT_LENGTH         -147    // Invalid length for Numeric Table initial value. Must be 1 to 29 characters.

#define O22_RESULT_DRIVER_NOT_FOUND                     -203    // Driver could not be found or loaded.
#define O22_RESULT_REGISTRY_WRITE_ERROR                 -204    // Could not write new entry to Windows Registry. Make sure you have administrative privileges for the operating system.
#define O22_RESULT_REGISTRY_READ_ERROR                  -205    // Could not read value(s) from Windows Registry.
#define O22_RESULT_OBJECT_NOT_FOUND_IN_REGISTRY         -206    // Startup data in Windows Registry is invalid or missing.
#define O22_RESULT_DUPLICATE_OBJECT_FOUND_IN_REGISTRY   -207    // Duplicate entry already exists in Windows Registry.

//-----------------------------------------------------------------------------
// DO NOT USE THIS GROUP OF ERROR CODES
// These codes are used by our Modbus Integration Kit; the values defined below
// ensure that we won't inadvertantly use them for something else, which would
// interfere with strategies that use Modbus
//-----------------------------------------------------------------------------
#define O22_RESULT_MODBUS_CRC_ERROR_RESERVED            -211
#define O22_RESULT_MODBUS_WRONG_SLAVE_ADDR_RESERVED     -212
#define O22_RESULT_MODBUS_LRC_ERROR_RESERVED            -213
#define O22_RESULT_MODBUS_OPEN_ERROR_RESERVED           -215
#define O22_RESULT_MODBUS_TIMEOUT_ERROR_RESERVED        -216
#define O22_RESULT_MODBUS_RESPONSE_MISMATCH_RESERVED    -217
//-----------------------------------------------------------------------------

#define O22_RESULT_NO_RESPONSE_FROM_MODEM               -300    // No response from modem during attempt to dial. Use HyperTerminal to make sure modem responds with 'OK' to the 'AT' command.
#define O22_RESULT_INCOMPATIBLE_PORT_TYPE               -301    // The type of port is invalid for this operation. For example, a dialing a modem was attempted on an ARCNET port. 
#define O22_RESULT_MODEM_DIAL_ERROR                     -302    // Error issuing a dial command to modem. Perhaps the dial string is empty.
#define O22_RESULT_MODEM_CONNECT_TIMEOUT                -303    // Timeout waiting for modem to connect.
#define O22_RESULT_MODEM_CONNECT_ERROR                  -304    // Could not connect. Phone line may be busy.
#define O22_RESULT_MODEM_HANDLE_ERROR                   -305    // Could not find modem handle. Hang up and dial again.


#define O22_RESULT_CONTROLLER_ALREADY_ACQUIRED          -400    // Control engine previously acquired by another process.
#define O22_RESULT_NOT_AUTHORIZED                       -401    // Authorization failed. More info may be available in a system log.
#define O22_RESULT_CONTROLLER_HANDLE_INVALID            -403    // Internal control engine handle invalid.
#define O22_RESULT_RPC_BINDING_ERROR                    -404    // RPC binding error. NetBios might not be running.
#define O22_RESULT_RPC_CALL_ERROR                       -405    // RPC call error. Verify that all appropriate protocols are installed and running.
#define O22_RESULT_CANT_ACQUIRE                         -406    // Control engine inaccessible. Cannot acquire lock.
#define O22_RESULT_FILE_NOT_FOUND                       -407    // File not found.
#define O22_RESULT_FILE_ACCESS_ERROR                    -408    // Error during file access.
#define O22_RESULT_OPERATION_CANCELLED_BY_USER          -409    // Operation cancelled by user.
#define O22_RESULT_DICTIONARY_INCOMPLETE                -410    // Dictionary is incomplete after flash download.
#define O22_RESULT_INVALID_SOCKET                       -411    // Ethernet: Invalid socket
#define O22_RESULT_SOCKET_CONNECT_ERROR                 -412    // Ethernet: Cannot connect error. Check IP address and subnet mask.
#define O22_RESULT_INVALID_DATA_STORE_NAME              -413    // Invalid idb file name.
#define O22_RESULT_OUT_OF_HANDLES                       -414    // Out of handles to open.
#define O22_RESULT_CANNOT_CREATE_FILE                   -415    // Cannot create file.
#define O22_RESULT_CANNOT_CREATE_TEMP_FILE              -416    // Cannot create temporary file.
#define O22_RESULT_CANNOT_OPEN_FILE                     -417    // Cannot open file.
#define O22_RESULT_CANNOT_READ_FILE                     -418    // Cannot read file.
#define O22_RESULT_INVALID_FILE_TYPE                    -419    // Not a valid PAC Control file.
#define O22_RESULT_INVALID_HANDLE                       -420    // Invalid handle.
#define O22_RESULT_NO_WRITE_ACCESS                      -421    // Write access not allowed.
#define O22_RESULT_CANNOT_COPY_TEMP_TO_CDB              -422    // Cannot copy temporary .idb file.
#define O22_RESULT_CANNOT_RENAME_TEMP_FILE              -423    // Cannot rename temporary file.
#define O22_RESULT_CANNOT_DELETE_TEMP_FILE              -424    // Cannot delete temporary file.
#define O22_RESULT_INVALID_STORAGE_FORMAT               -425    // Invalid storage format.
#define O22_RESULT_INCORRECT_OBJECT_COUNT               -426    // Incorrect number of objects specified.
#define O22_RESULT_INVALID_BITMASK                      -427    // Invalid bitmask for binary storage.
#define O22_RESULT_CANNOT_OPEN_DUMP_FILE                -428    // Cannot open dump output file.
#define O22_RESULT_CDB_FILE_FROM_NEWER_VERSION          -429    // The strategy you're attempting to open was last saved with a newer version of PAC Control than the one you're currently using. You may need to update your version of PAC Control. 
#define O22_RESULT_INVALID_DATA_RANGE                   -430    // Invalid data range. Verify high value is greater than low value.
#define O22_RESULT_CANNOT_RELEASE_OBJECT                -431    // Cannot release object/device (may not be locked).
#define O22_RESULT_CANNOT_UNLOCK_OBJECT                 -432    // Cannot unlock object/device (may not be locked) -- in use by another process.
#define O22_RESULT_OBJECT_ALREADY_LOCKED                -433    // Object/device already locked.
#define O22_RESULT_NOT_OWNER_ERROR                      -434    // The control engine is in use by another process on this computer, or may be unreachable.
#define O22_RESULT_INVALID_STRATEGY                     -435    // Check the strategy on the control engine.
#define O22_RESULT_MEMORY_EXCEPTION                     -436    // Memory exception during a database operation.
#define O22_RESULT_NO_SOCKETS                           -437    // No acceptable socket interface found.
#define O22_RESULT_ERROR_CREATING_SOCKET                -438    // Could not create socket.
#define O22_RESULT_NOT_CONNECTED_YET                    -439    // Not connected.
#define O22_RESULT_ERROR_ON_SOCKET_BIND                 -440    // Could not bind socket.
#define O22_RESULT_ERROR_ON_SOCKET_LISTEN               -441    // Not listening on socket.
#define O22_RESULT_ERROR_ON_SOCKET_ACCEPT               -442    // Could not accept on socket.
#define O22_RESULT_ERROR_ON_SOCKET_RECEIVE              -443    // Could not receive on socket.
#define O22_RESULT_ERROR_ON_SOCKET_SEND                 -444    // Could not send on socket.	
#define O22_RESULT_CDB_USER_REJECTED_UPGRADE            -445    // ioCdb: The file format change has been rejected by the user.
#define O22_RESULT_FTP_LOGIN_FAILED                     -446    // FTP: login failed. Check username, password, and max login on the server
#define O22_RESULT_FTP_CONNECT_FAILED                   -447    // FTP: connect failed. Check IP address and port.
#define O22_RESULT_FTP_COULD_NOT_CREATE_SESSION         -448    // FTP: could not create session. Check IP address and port.
#define O22_RESULT_FTP_COULD_NOT_SET_DATA_PORT          -449    // FTP: error while setting local port number that incoming data connections should use.
#define O22_RESULT_DNS_COULD_NOT_RESOLVE_HOSTNAME       -450    // DNS could not resolve host name to an IP address.
#define O22_RESULT_SMTP_LOGIN_FAILED                    -451    // SMTP: Login failed.  Check username and password.
#define O22_RESULT_FILE_ALREADY_EXISTS                  -452    // File already exists.
#define O22_RESULT_BAD_PATHNAME                         -453    // Invalid pathname or drive specification.
#define O22_RESULT_DNS_COULD_NOT_CONNECT                -454    // Unable to connect to DNS server. Check DNS and gateway configuration.
#define O22_RESULT_FTP_COULD_NOT_RESUME_DOWNLOAD        -455    // FTP: Unable to resume download.
#define O22_RESULT_BAD_ENCODING                         -456    // Unrecognized or bad encoding.
#define O22_RESULT_FILE_SIZE_EXCEEDED                   -457    // Maximum file size exceeded.
#define O22_RESULT_LOCAL_DISK_FULL                      -458    // Local disk is full.
#define O22_RESULT_REMOTE_DISK_FULL                     -459    // Remote disk is full.
#define O22_RESULT_REMOTE_FILE_NOT_FOUND                -460    // File not found on server.
#define O22_RESULT_PASSWORD_MISMATCH                    -461    // Passwords do not match
#define O22_RESULT_MUST_CHANGE_DEFAULTS                 -462    // Do not set to the default value.
#define O22_RESULT_INSUFFICIENT_PERMISSIONS             -463    // Insufficient permissions to perform the operation.
#define O22_RESULT_PATH_INACCESSIBLE                    -464    // Path points outside your accessible address space.
#define O22_RESULT_NOT_DIRECTORY                        -465    // Not a directory.
#define O22_RESULT_PATH_LOOP                            -466    // Too many symbolic links encountered in resolving path.
#define O22_RESULT_EXCESSIVE_LINKS                      -467    // Path would result in too many symbolic links.
#define O22_RESULT_IS_DIRECTORY                         -468    // Specified name is a directory.

#define O22_RESULT_NO_CONNECTIONDEF_ERROR               -500    // ConnectionDef missing or not defined.
#define O22_RESULT_FAIL_TO_OPEN_RECORDSET               -501    // Could not open recordset.
#define O22_RESULT_DAO_EXCEPTION                        -502    // DAO exception.
#define O22_RESULT_DB_TABLE_LENGTH_ERROR                -503    // Invalid database table length.
#define O22_RESULT_INVALID_DB_HANDSHAKE                 -504    // Invalid state for database handshake (neither IDLE, XFER_REQUEST nor STATE_IN_PROGRESS).
#define O22_RESULT_NO_DB_HANDSHAKE                      -505    // No database handshake found for the table.
#define O22_RESULT_ERRORLOG_WRITE_ERROR                 -506    // Could not write to ErrorLog.
#define O22_RESULT_WRITE_TO_INPUT_ERROR                 -507    // Cannot write to a digital/analog input. Only outputs may be written to.
#define O22_RESULT_INVALID_CONT_HANDSHAKE               -508    // Invalid state for control engine handshake (neither IDLE, XFER_REQUEST nor STATE_IN_PROGRESS).
#define O22_RESULT_CONT_HANDSHAKE_RESET_ERROR           -509    // Failure resetting control engine handshake.
#define O22_RESULT_CONT_HANDSHAKE_UPDATE_ERROR          -510    // Failure updating control engine handshake.
#define O22_RESULT_DB_WRITE_ERROR                       -511    // Failure writing to database.
#define O22_RESULT_DB_READ_ERROR                        -512    // Failure reading from database.
#define O22_RESULT_CONT_WRITE_ERROR                     -513    // Failure writing to control engine.
#define O22_RESULT_CONT_READ_ERROR                      -514    // Failure reading from control engine.
#define O22_RESULT_RT_TABLE_VALIDATE_ERROR              -515    // Runtime tables did not validate or were not created.
#define O22_RESULT_WRITE_RECORDSET_ERROR                -516    // Problem opening recordset for writing.
#define O22_RESULT_EMPTY_RECORD_ERROR                   -517    // Empty record in write table.
#define O22_RESULT_FAIL_TO_OPEN_RUNTIME_DB              -518    // Failure opening runtime database.
#define O22_RESULT_EMPTY_CONNECTIONDEF_ERROR            -519    // No tags to read/write.
#define O22_RESULT_FAIL_TO_OPEN_MPDB                    -520    // Failure opening master project database.
#define O22_RESULT_FAIL_TO_LOAD_PROJECT                 -521    // Failure loading project from master project database.
#define O22_RESULT_DELETE_TABLE_ERROR                   -522    // Could not delete contents of a table.
#define O22_RESULT_MISTIC_KERNEL_DOWNLOAD_NEEDED        -523    // Firmware version could not be read. Possible cause: firmware out of date.
#define O22_RESULT_INCOMPATIBLE_EPROM                   -524    // Could not read firmware version. Possible cause: EPROM out of date.
#define O22_RESULT_INCOMPATIBLE_STRATEGY_TIMEDATE_STAMP -525    // Strategy time/date stamp mismatch.
#define O22_RESULT_INCOMPATIBLE_STRATEGY_FILENAME       -526    // Strategy name mismatch.
#define O22_RESULT_INVALID_TYPEMASK                     -527    // Invalid typemask used.
#define O22_RESULT_ERROR_DELETING_RECORDS               -528    // Failure deleting records from table.
#define O22_RESULT_ERROR_WRITING_TO_RECORDSET           -529    // Failure writing to table.
#define O22_RESULT_UNKNOWN_CONTROLLER_NAME              -530    // Invalid control engine name. Control engine not configured (name not in Windows Registry). Make sure the control engine name is not misspelled.
#define O22_RESULT_BUFFER_FULL                          -531    // Buffer full.
#define O22_RESULT_BUFFER_EMPTY                         -532    // Buffer empty.
#define O22_RESULT_CONTROLLER_NOT_SUPPORTED             -533    // Control engine type mismatch. Control engine is not supported by this version of software.
#define O22_RESULT_MAX_IO_RETRY                         -534    // Attempt(s) to communicate with I/O Unit failed.
#define O22_RESULT_IO_REDUNDANT_SWITCH                  -535    // I/O unit has successfully switched to alternate target address.
#define O22_RESULT_ALL_TARGETS_DISABLED                 -536    // All target addresses disabled on I/O unit.
#define O22_RESULT_ALL_TARGETS_ASSIGNED                 -537    // All target addresses on I/O unit already assigned.
#define O22_RESULT_IO_ADDR_MISMATCH                     -538    // The address string passed does not match the passed I/O unit's address.
#define O22_RESULT_IO_RETRY                             -539    // I/O error; performing retry
#define O22_RESULT_STRATEGY_NOT_IN_FLASH                -540    // The strategy in RAM has not been burned to flash.
#define O22_RESULT_BAD_IO_UNIT_CONFIG                   -541    // A bad configuration was detected on an I/O unit
#define O22_RESULT_IO_CONFIG_COMPLETE                   -542    // I/O unit configuration completed
#define O22_RESULT_ALL_TARGETS_ATTEMPTED                -543    // Communications has been attempted with all configured I/O target addresses

// Redundant controller errors
#define O22_RESULT_REDUNDANCY_QUALIFY_FAIL              -600    // Redundant controller qualification failed.
#define O22_RESULT_REDUNDANT_NO_CONNECT                 -601    // Unable to connect to an active controller.
#define O22_RESULT_REDUNDANT_NOT_COMPATIBLE             -602    // Redundant backup controller is not compatible with active controller.
#define O22_RESULT_REDUNDANT_NO_MODE                    -603    // Redundant controller not yet set as active or backup.
#define O22_RESULT_REDUNDANT_KRN_FAIL                   -604    // Redundant backup firmware update failed.
#define O22_RESULT_REDUNDANT_PRG_FAIL                   -605    // Redundant backup strategy update failed.
#define O22_RESULT_REDUNDANT_MODE_BAD                   -606    // Redundant command issued on non-redundant, or wrong (active vs backup) controller.
#define O22_RESULT_REDUNDANT_SEQ_BAD                    -607    // Redundant command received out of order.
#define O22_RESULT_REDUNDANT_NO_TASK                    -608    // Redundant sync command received with no task ptr.
#define O22_RESULT_REDUNDANT_STEP_TIMEOUT               -609    // Redundant STEP command timeout.
#define O22_RESULT_REDUNDANT_MSG_FAIL                   -610    // Redundant message failure.
#define O22_RESULT_REDUNDANT_WRONG_PROG_TYPE            -611    // Cannot download redundant strategy to non-redundant controller or non-redundant strategy to redundant controller.
#define O22_RESULT_REDUNDANT_ENQUEUE_FAIL               -612    // Unable to enqueue sync command
#define O22_RESULT_REDUNDANT_CONFIG_FAIL                -613    // I/O configuration failed
#define O22_RESULT_REDUNDANT_INCOMPATIBLE_IO_FIRMWARE   -614    // Incompatible I/O unit firmware.
#define O22_RESULT_REDUNDANT_IO_OFFLINE                 -615    // Io monitor can not communicate with I/O unit.

// PID error codes
#define O22_RESULT_PID_LOOP_ALGO_NOT_NONE_BASE          -699    // A PID Loop has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_0_ALGO_NOT_NONE             -700    // PID Loop 0 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_1_ALGO_NOT_NONE             -701    // PID Loop 1 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_2_ALGO_NOT_NONE             -702    // PID Loop 2 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_3_ALGO_NOT_NONE             -703    // PID Loop 3 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_4_ALGO_NOT_NONE             -704    // PID Loop 4 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_5_ALGO_NOT_NONE             -705    // PID Loop 5 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_6_ALGO_NOT_NONE             -706    // PID Loop 6 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_7_ALGO_NOT_NONE             -707    // PID Loop 7 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_8_ALGO_NOT_NONE             -708    // PID Loop 8 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_9_ALGO_NOT_NONE             -709    // PID Loop 9 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_10_ALGO_NOT_NONE            -710    // PID Loop 10 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_11_ALGO_NOT_NONE            -711    // PID Loop 11 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_12_ALGO_NOT_NONE            -712    // PID Loop 12 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_13_ALGO_NOT_NONE            -713    // PID Loop 13 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_14_ALGO_NOT_NONE            -714    // PID Loop 14 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_15_ALGO_NOT_NONE            -715    // PID Loop 15 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_16_ALGO_NOT_NONE            -716    // PID Loop 16 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_17_ALGO_NOT_NONE            -717    // PID Loop 17 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_18_ALGO_NOT_NONE            -718    // PID Loop 18 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_19_ALGO_NOT_NONE            -719    // PID Loop 19 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_20_ALGO_NOT_NONE            -720    // PID Loop 20 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_21_ALGO_NOT_NONE            -721    // PID Loop 21 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_22_ALGO_NOT_NONE            -722    // PID Loop 22 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_23_ALGO_NOT_NONE            -723    // PID Loop 23 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_24_ALGO_NOT_NONE            -724    // PID Loop 24 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_25_ALGO_NOT_NONE            -725    // PID Loop 25 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_26_ALGO_NOT_NONE            -726    // PID Loop 26 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_27_ALGO_NOT_NONE            -727    // PID Loop 27 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_28_ALGO_NOT_NONE            -728    // PID Loop 28 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_29_ALGO_NOT_NONE            -729    // PID Loop 29 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_30_ALGO_NOT_NONE            -730    // PID Loop 30 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_31_ALGO_NOT_NONE            -731    // PID Loop 31 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_32_ALGO_NOT_NONE            -732    // PID Loop 32 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_33_ALGO_NOT_NONE            -733    // PID Loop 33 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_34_ALGO_NOT_NONE            -734    // PID Loop 34 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_35_ALGO_NOT_NONE            -735    // PID Loop 35 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_36_ALGO_NOT_NONE            -736    // PID Loop 36 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_37_ALGO_NOT_NONE            -737    // PID Loop 37 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_38_ALGO_NOT_NONE            -738    // PID Loop 38 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_39_ALGO_NOT_NONE            -739    // PID Loop 39 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_40_ALGO_NOT_NONE            -740    // PID Loop 40 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_41_ALGO_NOT_NONE            -741    // PID Loop 41 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_42_ALGO_NOT_NONE            -742    // PID Loop 42 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_43_ALGO_NOT_NONE            -743    // PID Loop 43 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_44_ALGO_NOT_NONE            -744    // PID Loop 44 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_45_ALGO_NOT_NONE            -745    // PID Loop 45 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_46_ALGO_NOT_NONE            -746    // PID Loop 46 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_47_ALGO_NOT_NONE            -747    // PID Loop 47 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_48_ALGO_NOT_NONE            -748    // PID Loop 48 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_49_ALGO_NOT_NONE            -749    // PID Loop 49 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_50_ALGO_NOT_NONE            -750    // PID Loop 50 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_51_ALGO_NOT_NONE            -751    // PID Loop 51 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_52_ALGO_NOT_NONE            -752    // PID Loop 52 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_53_ALGO_NOT_NONE            -753    // PID Loop 53 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_54_ALGO_NOT_NONE            -754    // PID Loop 54 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_55_ALGO_NOT_NONE            -755    // PID Loop 55 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_56_ALGO_NOT_NONE            -756    // PID Loop 56 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_57_ALGO_NOT_NONE            -757    // PID Loop 57 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_58_ALGO_NOT_NONE            -758    // PID Loop 58 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_59_ALGO_NOT_NONE            -759    // PID Loop 59 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_60_ALGO_NOT_NONE            -760    // PID Loop 60 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_61_ALGO_NOT_NONE            -761    // PID Loop 61 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_62_ALGO_NOT_NONE            -762    // PID Loop 62 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_63_ALGO_NOT_NONE            -763    // PID Loop 63 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_64_ALGO_NOT_NONE            -764    // PID Loop 64 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_65_ALGO_NOT_NONE            -765    // PID Loop 65 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_66_ALGO_NOT_NONE            -766    // PID Loop 66 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_67_ALGO_NOT_NONE            -767    // PID Loop 67 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_68_ALGO_NOT_NONE            -768    // PID Loop 68 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_69_ALGO_NOT_NONE            -769    // PID Loop 69 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_70_ALGO_NOT_NONE            -770    // PID Loop 70 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_71_ALGO_NOT_NONE            -771    // PID Loop 71 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_72_ALGO_NOT_NONE            -772    // PID Loop 72 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_73_ALGO_NOT_NONE            -773    // PID Loop 73 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_74_ALGO_NOT_NONE            -774    // PID Loop 74 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_75_ALGO_NOT_NONE            -775    // PID Loop 75 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_76_ALGO_NOT_NONE            -776    // PID Loop 76 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_77_ALGO_NOT_NONE            -777    // PID Loop 77 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_78_ALGO_NOT_NONE            -778    // PID Loop 78 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_79_ALGO_NOT_NONE            -779    // PID Loop 79 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_80_ALGO_NOT_NONE            -780    // PID Loop 80 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_81_ALGO_NOT_NONE            -781    // PID Loop 81 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_82_ALGO_NOT_NONE            -782    // PID Loop 82 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_83_ALGO_NOT_NONE            -783    // PID Loop 83 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_84_ALGO_NOT_NONE            -784    // PID Loop 84 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_85_ALGO_NOT_NONE            -785    // PID Loop 85 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_86_ALGO_NOT_NONE            -786    // PID Loop 86 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_87_ALGO_NOT_NONE            -787    // PID Loop 87 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_88_ALGO_NOT_NONE            -788    // PID Loop 88 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_89_ALGO_NOT_NONE            -789    // PID Loop 89 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_90_ALGO_NOT_NONE            -790    // PID Loop 90 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_91_ALGO_NOT_NONE            -791    // PID Loop 91 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_92_ALGO_NOT_NONE            -792    // PID Loop 92 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_93_ALGO_NOT_NONE            -793    // PID Loop 93 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_94_ALGO_NOT_NONE            -794    // PID Loop 94 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.
#define O22_RESULT_PID_LOOP_95_ALGO_NOT_NONE            -795    // PID Loop 95 has been configured outside of this strategy (in PAC Manager or in another strategy), and could conflict with this strategy's logic.

// network client error codes
#define O22_RESULT_PKI_BAD_CERTIFICATE                  -2000   // PKI: Bad certificate
#define O22_RESULT_PKI_CERTIFICATE_REVOKED              -2001   // PKI: Certificate revoked
#define O22_RESULT_PKI_CERTIFICATE_EXPIRED              -2002   // PKI: Certificate expired
#define O22_RESULT_PKI_CERTIFICATE_UNMATCHED            -2003   // PKI: Certificate unmatched
#define O22_RESULT_PKI_PRIV_KEY_ADD_FAIL                -2004   // PKI: Unable to add private key
#define O22_RESULT_PKI_CERTIFICATE_UNKNOWN_CA           -2005   // PKI: Certificate signed by unknown CA
#define O22_RESULT_PKI_CERTIFICATES_NOT_FOUND           -2006   // PKI: No root certificates found
#define O22_RESULT_PKI_CERTIFICATE_LOAD_FAIL            -2007   // PKI: Error loading trust store
#define O22_RESULT_PKI_CERTIFICATE_SELF_SIGNED          -2008   // PKI: Self-signed certificate

#define O22_RESULT_SSL_CLIENT_START_FAIL                -2100   // SSL: Client start failure
#define O22_RESULT_SSL_CLIENT_STOP_FAIL                 -2101   // SSL: Client stop failure
#define O22_RESULT_SSL_FLUSH_FAIL                       -2102   // SSL: Write stream flush failure
#define O22_RESULT_SSL_HANDSHAKE_FAIL                   -2103   // SSL: Handshake failed
#define O22_RESULT_SSL_HANDSHAKE_BAD_CERTIFICATE        -2104   // SSL: Handshake failed due to invalid or unverifiable certificate
#define O22_RESULT_SSL_UNSPECIFIED_ASYNC_ERROR          -2105   // SSL: Unspecified asynchronous platform error
#define O22_RESULT_SSL_SESSION_NOT_OPEN                 -2106   // SSL: SSL session is not open
#define O22_RESULT_SSL_ENGINE_NOT_FOUND                 -2107   // SSL: Crypto engine not found
#define O22_RESULT_SSL_ENGINE_SET_FAILED                -2108   // SSL: Cannot set default SSL engine
#define O22_RESULT_SSL_BAD_CIPHER                       -2109   // SSL: Couldn't use specified cipher
#define O22_RESULT_SSL_SERVER_START_FAIL                -2110   // SSL: Server start failure
#define O22_RESULT_SSL_SERVER_STOP_FAIL                 -2111   // SSL: Server stop failure

#define O22_RESULT_SIGNED_IMAGE_VERIFY_FAIL             -2200   // Image digital signature verification failed

#define O22_RESULT_INVALID_PROTOCOL                     -8607   // Invalid protocol.
#define O22_RESULT_PORT_INITIALIZE_FAILED               -8608   // Port initialization failed. 
#define O22_RESULT_NO_OTHER_NODES_ON_ARCNET             -8609   // Could not find other nodes in ARCNET.
#define O22_RESULT_BAUD_RATE_INVALID                    -8610   // Baud rate is not valid/supported.
#define O22_RESULT_NO_DATA_RECEIVED                     -8611   // No data received. //-8611 // TRACEIV.CPP
#define O22_RESULT_OLD_RESPONSE_TO_NEW_COMMAND          -8612   // Old response to new command.
#define O22_RESULT_OUT_OF_SERIALDATA_SPACE_ERROR        -8613   // Out of memory (in the SerialData global array).
#define O22_RESULT_CONNECTION_TYPE_INVALID              -8614   // Connection type is invalid.
#define O22_RESULT_CONTROLLER_DOES_NOT_HAVE_FLASH       -8615   // Control engine does not have flash EPROM.
#define O22_RESULT_INVALID_CONTROLLER_VERSION           -8616   // Invalid control engine firmware version
#define O22_RESULT_FPROGRAM_ERROR                       -8617   // Error occurred while storing to flash EPROM.
#define O22_RESULT_NO_B3000_FOUND                       -8618   // No B3000 found.
#define O22_RESULT_NETBIOS_CONNECT_ERROR                -8619   // NetBios connect error.
#define O22_RESULT_CDB_UNKNOWN_ERROR                    -8620   // ioCdb: Unknown error.
#define O22_RESULT_NO_TIMEX_AVAILABLE_ERROR             -8621   // Ran out of locking objects.
#define O22_RESULT_RECEIVED_FROM_WRONG_NODE             -8622   // Response not from the expected node.
#define O22_RESULT_MUTUAL_EXCLUSION_CREATE_ERROR        -8623   // WinRT: Mutual Exclusion could not be created.
#define O22_RESULT_MUTUAL_EXCLUSION_DELETE_ERROR        -8624   // WinRT: Mutual Exclusion could not be deleted.
#define O22_RESULT_CANNOT_CREATE_OR_DUPLICATE           -8625   // Could not create a handle. Possible cause: port in use by another application.
#define O22_RESULT_INVALID_CONTROLLER_NAME              -8626   // Control engine name does not exist in the controller names repository. Make sure the control engine name is not misspelled.


#define O22_RESULT_WSAEACCES                            -10013  // Ethernet socket error:Permission denied.
#define O22_RESULT_WSAEADDRINUSE                        -10048  // Ethernet socket error:Address already in use.
#define O22_RESULT_WSAEADDRNOTAVAIL                     -10049  // Ethernet socket error:Cannot assign requested address.
#define O22_RESULT_WSAEAFNOSUPPORT                      -10047  // Ethernet socket error:Address family not supported by protocol family.
#define O22_RESULT_WSAEALREADY                          -10037  // Ethernet socket error:Operation already in progress.
#define O22_RESULT_WSAECONNABORTED                      -10053  // Ethernet socket error:Software caused connection abort.
#define O22_RESULT_WSAECONNREFUSED                      -10061  // Ethernet socket error:Connection refused.
#define O22_RESULT_WSAECONNRESET                        -10054  // Ethernet socket error:Connection reset by peer.
#define O22_RESULT_WSAEDESTADDRREQ                      -10039  // Ethernet socket error:Destination address required.
#define O22_RESULT_WSAEFAULT                            -10014  // Ethernet socket error:Bad address.
#define O22_RESULT_WSAEHOSTDOWN                         -10064  // Ethernet socket error:Host is down.
#define O22_RESULT_WSAEHOSTUNREACH                      -10065  // Ethernet socket error:No route to host.
#define O22_RESULT_WSAEINPROGRESS                       -10036  // Ethernet socket error:Operation now in progress.
#define O22_RESULT_WSAEINTR                             -10004  // Ethernet socket error:Interrupted function call.
#define O22_RESULT_WSAEINVAL                            -10022  // Ethernet socket error:Invalid argument.
#define O22_RESULT_WSAEISCONN                           -10056  // Ethernet socket error:Socket is already connected.
#define O22_RESULT_WSAEMFILE                            -10024  // Ethernet socket error:Too many open files.
#define O22_RESULT_WSAEMSGSIZE                          -10040  // Ethernet socket error:Message too long.
#define O22_RESULT_WSAENETDOWN                          -10050  // Ethernet socket error:Network is down.
#define O22_RESULT_WSAENETRESET                         -10052  // Ethernet socket error:Network dropped connection on reset.
#define O22_RESULT_WSAENETUNREACH                       -10051  // Ethernet socket error:Network is unreachable.
#define O22_RESULT_WSAENOBUFS                           -10055  // Ethernet socket error:No buffer space available.
#define O22_RESULT_WSAENOPROTOOPT                       -10042  // Ethernet socket error:Bad protocol option.
#define O22_RESULT_WSAENOTCONN                          -10057  // Ethernet socket error:Socket is not connected.
#define O22_RESULT_WSAENOTSOCK                          -10038  // Timeout while connecting to device. Check hardware connection, address, power, and jumpers.
#define O22_RESULT_WSAEOPNOTSUPP                        -10045  // Ethernet socket error:Operation not supported.
#define O22_RESULT_WSAEPFNOSUPPORT                      -10046  // Ethernet socket error:Protocol family not supported.
#define O22_RESULT_WSAEPROCLIM                          -10067  // Ethernet socket error:Too many processes.
#define O22_RESULT_WSAEPROTONOSUPPORT                   -10043  // Ethernet socket error:Protocol not supported.
#define O22_RESULT_WSAEPROTOTYPE                        -10041  // Ethernet socket error:Protocol wrong type for socket.
#define O22_RESULT_WSAESHUTDOWN                         -10058  // Ethernet socket error:Cannot send after socket shutdown.
#define O22_RESULT_WSAESOCKTNOSUPPORT                   -10044  // Ethernet socket error:Socket type not supported.
#define O22_RESULT_WSAETIMEDOUT                         -10060  // Ethernet socket error:Connection timed out.
#define O22_RESULT_WSATYPE_NOT_FOUND                    -10109  // Ethernet socket error:Class type not found.
#define O22_RESULT_WSAEWOULDBLOCK                       -10035  // Ethernet socket error:Resource temporarily unavailable.
#define O22_RESULT_WSAHOST_NOT_FOUND                    -11001  // Ethernet socket error:Host not found.
#define O22_RESULT_WSANOTINITIALISED                    -10093  // Ethernet socket error:Successful startup not yet performed.
#define O22_RESULT_WSANO_DATA                           -11004  // Ethernet socket error:Valid name, no data record of requested type.
#define O22_RESULT_WSANO_RECOVERY                       -11003  // Ethernet socket error:This is a nonrecoverable error.
#define O22_RESULT_WSASYSNOTREADY                       -10091  // Ethernet socket error:Network subsystem is unavailable.
#define O22_RESULT_WSATRY_AGAIN                         -11002  // Ethernet socket error:Nonauthoritative host not found.
#define O22_RESULT_WSAVERNOTSUPPORTED                   -10092  // Ethernet socket error:Version out of range.
#define O22_RESULT_WSAEDISCON                           -10101  // Ethernet socket error:Asynchronous message sent.

#define O22_RESULT_FAILED_TO_OPEN_XTLR_FILE             -13000  // Controller database file not found.
#define O22_RESULT_UNSUPPORTED_LIBRARY_FUNCTION         -13001  // Library does not support requested function.
#define O22_RESULT_BAD_STREAM_METHOD_STRING             -13002  // Error in the opening method string.
#define O22_RESULT_INVALID_METHOD_ARGUMENT              -13003  // Invalid method argument created.
#define O22_RESULT_DATA_SEND_ERROR                      -13004  // Data sent doesn't match returned value.
#define O22_RESULT_INVALID_DRIVER_FUNCTION              -13005  // A driver function was not found.
#define O22_RESULT_INVALID_IOCTL_FUNCTION               -13006  // An invalid ioctl function was requested.
#define O22_RESULT_SERIAL_EOM_NOT_SET                   -13007  // The serial driver end-of-message (EOM) character was not set.
#define O22_RESULT_NO_MODULES_FOUND                     -13008  // No driver transport modules found.
#define O22_RESULT_MODULE_FUNCTION_NOT_FOUND            -13009  // The requested function name not found in module.
#define O22_RESULT_CONTROLLER_NOT_FOUND                 -13010  // The named controller was not found in the list.
#define O22_RESULT_CONTROLLER_LIST_FULL                 -13011  // The limit of controllers in the list is reached.
#define O22_RESULT_STRANGE                              -13012  // Strange error; ever have one of those days.
#define O22_RESULT_FAIL                                 -13013  // Simple fail flag.
#define O22_RESULT_RESPONSE_SHORT                       -13014  // Short response received.
#define O22_RESULT_LIBRARY_PATH_NOT_FOUND               -13015  // Library env variable not found.
#define O22_RESULT_BUFFER_TOO_SMALL                     -13016  // Buffer size is too small for protocol.
#define O22_RESULT_MISSING_ENVIRONMENT_VARIABLE         -13017  // An opto 22 system environment variable was not found.
#define O22_RESULT_ERROR_ON_SOCKET_OPT_BROADCAST        -13018  // Setting the socket broadcast option failed.
#define O22_RESULT_BAD_PARAMETER                        -13019  // An argument in a string is bad.
#define O22_RESULT_MISCONFIGURED_POINT                  -13020  // A misconfigured point error is reported. (Check brain's module configuration)
#define O22_RESULT_SEQUENCE_ID_MISMATCH                 -13021  // Sequence ID mismatch. Somehow the response sequence ID doen't match the command's.
#define O22_RESULT_PACKET_ID_MISMATCH                   -13022  // Packet response id was not expected to be received.
#define O22_RESULT_FAILED_TO_ACQUIRE_OBJECT_LOCK        -13023  // Failed to acquire the object lock.
#define O22_RESULT_BAD_SIGNATURE_LENGTH                 -13024  // The signature lengths don't match.
#define O22_RESULT_MISMATCHING_SIGNATURE                -13025  // The signatures don't match.
#define O22_RESULT_OBJECT_NOT_INITIALIZED               -13026  // The object's initialize or open hasn't been called.
#define O22_RESULT_TIMEOUT_ERROR                        -13027  // Function called reports a general timeout
#define O22_RESULT_OBJECT_NOT_OPEN                      -13028  // The object is not open.
#define O22_RESULT_OBJECT_CANNOT_BE_MODIFIED            -13029  // Object is already initialized with engine and cannot be modified.
#define O22_RESULT_UNKNOWN_OBJECT_TYPE                  -13030  // Unknown object type. Inspect tag name for error
#define O22_RESULT_LIST_FULL                            -13031  // Another object was added to a full list. Inspect the list size.
#define O22_RESULT_INVALID_TYPE                         -13032  // An invalid option data type was referenced.
#define O22_RESULT_COMMAND_VALIDATION_FAILED            -13033  // A 4-pass command validation failed.
#define O22_RESULT_OPTOMUX_PROTO_PUC_EXPECTED           -13034  // Optomux Brain reports a power up clear was expected. It reset or power cycled since last command.
#define O22_RESULT_OPTOMUX_PROTO_UNDEF_COMMAND          -13035  // Optomux Brain reports an unknown command was received.
#define O22_RESULT_OPTOMUX_PROTO_CHECKSUM_ERROR         -13036  // Optomux Brain reports a command with a bad checksum was received.
#define O22_RESULT_OPTOMUX_PROTO_INPUT_BUFFER_OVER      -13037  // Optomux Brain reports that too many characters were received (missing a carriage return).
#define O22_RESULT_OPTOMUX_PROTO_NON_PRINTABLE_ASCII    -13038  // Optomux Brain reports that non-printable ASCII characters were received.
#define O22_RESULT_OPTOMUX_PROTO_DATA_FIELD_ERROR       -13039  // Optomux Brain reports that the command received has an out of range data field(s).
#define O22_RESULT_OPTOMUX_PROTO_WATCHDOG_TIMEOUT       -13040  // Optomux Brain reports that the communication watchdog timed out (activated).
#define O22_RESULT_OPTOMUX_PROTO_INVALID_LIMITS_SET     -13041  // Optomux Brain reports that the command received has invalid limits.
#define O22_RESULT_CONNECTION_NOT_RESOLVED_YET          -13042  // A stream connection is still in progress.
#define O22_RESULT_TABLE_LIST_DIRTY                     -13043  // The object table is dirty when trying to read the object table.
#define O22_RESULT_ASYMMETRIC_TABLE                     -13044  // The object table has incompatible data types.
#define O22_RESULT_INVALID_OBJECT_FEATURE               -13045  // The engine read function received an invalid object feature type.
#define O22_RESULT_TAG_IS_NOT_AN_OBJECT                 -13046  // The tag inspected is not an object; it might be a dictionary word.
#define O22_RESULT_ENVIRONMENT_VARIABLE_MISSING         -13047  // A system environment variable (OPTOCONFIG or OPTOUSER) is missing
#define O22_RESULT_EMPTY_LIST                           -13048  // The List is empty, no items to return.
#define O22_RESULT_CONNECTION_CLOSED                    -13049  // A remote host closed or shut down a TCP session. Not necessarily an error.
#define O22_RESULT_STREAM_NOT_ACCEPTED                  -13050  // The stream being closed was not created by the Accept member function.
#define O22_RESULT_CLIENT_ABORTED_OPERATION             -13051  // The operation was aborted by the client application.
#define O22_RESULT_TOO_MUCH_DATA_RECEIVED               -13052  // The operation returned more data than was expected.
#define O22_RESULT_COMMAND_TOO_LARGE                    -13053  // The command buffer created is too large.
#define O22_RESULT_WINDOWS_WINSOCK_SUCKS                -13054  // Winsock configuration is wrong or missing from the system.
#define O22_RESULT_INVALID_HOST_NAME_OR_IP_ADDR         -13055  // Host name or address is invalid.
#define O22_RESULT_ALREADY_CONFIGURED                   -13056  // This device is already configured and cannot be reconfigured.
#define O22_RESULT_YOU_WANT_WHAT_QUESTIONMARK           -13057  // A requested device (index, name,...) doesn't exist.
#define O22_RESULT_SAY_WHAT_QUESTIONMARK                -13058  // The response from a device in unrecognizable or changed unexpectedly.
#define O22_RESULT_WINSOCK_WSANOTINITIALISED            -13059  // Winsock library not initialized.
#define O22_RESULT_WINSOCK_WSAENETDOWN                  -13060  // Ethernet connection is down.
#define O22_RESULT_WINSOCK_WSAEFAULT                    -13061  // The buf parameter is not completely contained in a valid part of the user address space.
#define O22_RESULT_WINSOCK_WSAENOTCONN                  -13062  // The socket is not connected.
#define O22_RESULT_WINSOCK_WSAENETRESET                 -13063  // The connection has been broken; the keep-alive function detected a failure while the operation was in progress.
#define O22_RESULT_WINSOCK_WSAENOTSOCK                  -13064  // The file descriptor is not a socket.
#define O22_RESULT_WINSOCK_WSAEOPNOTSUPP                -13065  // The socket option is not supported.
#define O22_RESULT_WINSOCK_WSAESHUTDOWN                 -13066  // The socket has been shut down by remote host.
#define O22_RESULT_WINSOCK_WSAEWOULDBLOCK               -13067  // The socket is marked as nonblocking and the receive operation would block.
#define O22_RESULT_WINSOCK_WSAEMSGSIZE                  -13068  // The message size of the socket is invalid.
#define O22_RESULT_WINSOCK_WSAEINVAL                    -13069  // The socket is invalid.
#define O22_RESULT_WINSOCK_WSAECONNABORTED              -13070  // The connection is aborted.
#define O22_RESULT_WINSOCK_WSAETIMEDOUT                 -13071  // The connection has timed out.
#define O22_RESULT_WINSOCK_WSAECONNRESET                -13072  // The connection has been reset by a remote host.

// -22001 through -22300 are reserved for customer use!!
#define O22_RESULT_USER_DEFINED_MESSAGE                 -22000 // User-defined message.

#define O22_RESULT_UNDEFINED_ERROR_CODE                 -32767 // Undefined error reported. Contact Opto 22 Product Support.


// __END_ERROR_CODES__

#endif  // __IOLIB_ERROR_CODES_HDR__
