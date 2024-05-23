include_guard(DIRECTORY)

#[[
    Create the names of output files preserving relative dirs. (Ported from MOC command)

    qm_create_protobuf(<OUT>
        INPUT <files...>
        [OUTPUT_DIR <dir>]
        [INCLUDE_DIRECTORIES <dirs...>]
        [OPTIONS <options...>]
        [DEPENDS <deps...>]
        [CREATE_ONCE]
    )

    INPUT: source files
    OUTPUT_DIR: output directory

    INCLUDE_DIRECTORIES: extra include directories
    OPTIONS: extra options passed to protobuf compiler
    DEPENDS: dependencies

    CREATE_ONCE: create proto code files at configure phase if not exist

    OUT: output source file paths
#]]
function(qm_create_protobuf _out)
    set(options CREATE_ONCE)
    set(oneValueArgs OUTPUT_DIR)
    set(multiValueArgs INPUT INCLUDE_DIRECTORIES OPTIONS DEPENDS)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Find `protoc`
    if(NOT PROTOC_EXECUTABLE)
        if(NOT TARGET protobuf::protoc)
            message(FATAL_ERROR "qm_create_protobuf: target `protobuf::protoc` not found. Add find_package(Protobuf) to CMake to enable.")
        endif()

        get_target_property(PROTOC_EXECUTABLE protobuf::protoc LOCATION)

        if(NOT PROTOC_EXECUTABLE)
            message(FATAL_ERROR "qm_create_protobuf: failed to get the location of`protoc`.")
        endif()

        # Cache value
        set(PROTOC_EXECUTABLE ${PROTOC_EXECUTABLE} PARENT_SCOPE)
    endif()

    if(NOT FUNC_INPUT)
        message(FATAL_ERROR "qm_create_protobuf: INPUT not specified.")
    endif()

    if(FUNC_OUTPUT_DIR)
        set(_out_dir ${FUNC_OUTPUT_DIR})
    else()
        set(_out_dir ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    # Collect include paths and out files
    set(_include_options)
    set(_out_files)
    set(_input_names)

    foreach(_item IN LISTS FUNC_INCLUDE_DIRECTORIES)
        get_filename_component(_abs_path ${_item} ABSOLUTE)
        list(APPEND _include_options -I${_abs_path})
    endforeach()

    foreach(_item IN LISTS FUNC_INPUT)
        get_filename_component(_item ${_item} ABSOLUTE)
        get_filename_component(_abs_path ${_item} DIRECTORY)
        list(APPEND _include_options -I${_abs_path})

        get_filename_component(_name ${_item} NAME_WLE)
        list(APPEND _out_files ${_out_dir}/${_name}.pb.h ${_out_dir}/${_name}.pb.cc)

        get_filename_component(_full_name ${_item} NAME)
        list(APPEND _input_names ${_full_name})
    endforeach()

    list(REMOVE_DUPLICATES _include_options)

    if(FUNC_CREATE_ONCE)
        set(_need_create off)

        foreach(_item IN LISTS _out_files)
            if(NOT EXISTS ${_item})
                set(_need_create on)
                break()
            endif()
        endforeach()

        if(_need_create)
            string(JOIN ", " _input_to_print ${_input_names})
            message(STATUS "Protoc: Generate sources for ${_input_to_print}")
            execute_process(COMMAND
                ${PROTOC_EXECUTABLE} --cpp_out=${_out_dir} ${_include_options} ${FUNC_OPTIONS} ${_input_names}
            )
        endif()
    endif()

    add_custom_command(
        OUTPUT ${_out_files}
        COMMAND ${PROTOC_EXECUTABLE} --cpp_out=${_out_dir} ${_include_options} ${FUNC_OPTIONS} ${_input_names}
        DEPENDS ${FUNC_INPUT} ${FUNC_DEPENDS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        VERBATIM
    )

    set(${_out} ${_out_files} PARENT_SCOPE)
endfunction()
