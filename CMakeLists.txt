cmake_minimum_required(VERSION 3.7)
project(CoMDRHT)

set(CMAKE_BUILD_TYPE Release) # optimizations, but debuging is not allowed
#set(CMAKE_BUILD_TYPE Debug) # NO optimizations, debuging allowed

#set(CMAKE_VERBOSE_MAKEFILE ON)


find_package(MPI REQUIRED)

include_directories(${MPI_INCLUDE_PATH})

set(CMAKE_CXX_STANDARD 11)

#-ftree-vectorize

# fast math or not, there is a problem when nan values are found when this options is enabled
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffast-math")

# General compilation flags
add_definitions(-DUSING_MPI -DMPICH_IGNORE_CXX_SEEK -DDO_MPI)
add_definitions(-ftree-vectorize -flto -funroll-all-loops -mavx2)
add_definitions(-DPRINT_OUTPUT=0 -DPERCENTAGE_OF_REPLICATION=0 -lm -D_GNU_SOURCE)
#add_definitions(-DOUR_IMPROVEMENTS=1)
# These are other approaches of the literature
#add_definitions(-DAPPROACH_USING_POINTERS=1)
#add_definitions(-DAPPROACH_ALREADY_CONSUMED=1)
#add_definitions(-DAPPROACH_WANG=1)

#add_definitions(-DJUST_VOLATILES=1)

# These are our approaches
#add_definitions(-DAPPROACH_MIX_WANG=1)
#add_definitions(-DAPPROACH_MIX_IMPROVED=1)
#add_definitions(-DVAR_GROUPING=1) # it can be used with any of the above approaches

# no longer used
#add_definitions(-DSKIP_VOLATILE=1)
#add_definitions(-DAPPROACH_NEW_LIMIT=1)
#add_definitions(-DAPPROACH_WRITE_INVERTED_NEW_LIMIT=1)

#Init flags current
set(FLAGS_CURRENT "anything")

set(SOURCE_FILES
        CoMD.c cmdLineParser.h cmdLineParser.c CoMD_info.h CoMDTypes.h
        RHT.h RHT.c
        constants.h decomposition.h decomposition.c eam.h eam.c haloExchange.h haloExchange.c
        initAtoms.h initAtoms.c linkCells.h linkCells.c ljForce.h ljForce.c
        memUtils.h mycommand.h mycommand.c mytype.h parallel.h parallel.c
        performanceTimers.h performanceTimers.c random.h random.c timestep.h timestep.c
        yamlOutput.h yamlOutput.c
        )

function(createExecutable exeName compFlags varFlag ourImprovs groupSize)
    add_executable(${exeName} ${SOURCE_FILES})
    #this line causes problems when used with cmake 3.7 (version of g5k machines)
    #set_target_properties(${exeName} PROPERTIES COMPILE_FLAGS "${compFlags}")
    set_property(TARGET ${exeName} APPEND PROPERTY COMPILE_DEFINITIONS ${compFlags})
    if(varFlag EQUAL 1)
        set_property(TARGET ${exeName} APPEND PROPERTY COMPILE_DEFINITIONS "VAR_GROUPING=1")
    endif()
    if(varFlag EQUAL 2)
        set_property(TARGET ${exeName} APPEND PROPERTY COMPILE_DEFINITIONS "JUST_VOLATILES=1")
    endif()
    if(ourImprovs EQUAL 1)
        set_property(TARGET ${exeName} APPEND PROPERTY COMPILE_DEFINITIONS "OUR_IMPROVEMENTS=1")
    endif()

    set_property(TARGET ${exeName} APPEND PROPERTY COMPILE_DEFINITIONS "GROUP_GRANULARITY=${groupSize}")

    target_link_libraries(${exeName} ${MPI_LIBRARIES})
    target_link_libraries(${exeName} pthread)
    target_link_libraries(${exeName} m) #math
    if(MPI_COMPILE_FLAGS)
        set_target_properties(${exeName} PROPERTIES COMPILE_FLAGS "${MPI_COMPILE_FLAGS}")
    endif()

    if(MPI_LINK_FLAGS)
        set_target_properties(${exeName} PROPERTIES LINK_FLAGS "${MPI_LINK_FLAGS}")
    endif()
endfunction(createExecutable)


#current, for testing
#createExecutable("CoMD-Current" ${FLAGS_CURRENT} 2 1)

# using pointer flags
set(FLAGS_USING_POINTERS "${CMAKE_CXX_FLAGS} -DAPPROACH_USING_POINTERS=1")

# using already consumed value flags
set(FLAGS_ALREADY_CONSUMED "${CMAKE_CXX_FLAGS} -DAPPROACH_ALREADY_CONSUMED=1")

# using no sync consumer approachh
set(FLAGS_NO_SYNC_CONSUMER "${CMAKE_CXX_FLAGS} -DAPPROACH_CONSUMER_NO_SYNC=1")

# using new limit approach (includes the previous)
set(FLAGS_NEW_LIMIT "${CMAKE_CXX_FLAGS} -DAPPROACH_NEW_LIMIT=1")

# using new limit write inverted approach
set(FLAGS_NEW_LIMIT_INVERTED "${CMAKE_CXX_FLAGS} -DAPPROACH_WRITE_INVERTED_NEW_LIMIT=1")

# using wang approach
set(FLAGS_WANG "${CMAKE_CXX_FLAGS} APPROACH_WANG=1")

# using mix-wang approach
set(FLAGS_MIX_WANG "APPROACH_MIX_WANG=1")

# using mix-wang improved approach
set(FLAGS_MIX_WANG_IMPROVED "APPROACH_MIX_IMPROVED=1")

# un comment the next lines to create multiple executables, with different configurations
#using pointers
#createExecutable("CoMD-RHT-UP" ${FLAGS_USING_POINTERS} 0)
#createExecutable("CoMD-RHT-UP-VG" ${FLAGS_USING_POINTERS} 1)

# already consumed
#createExecutable("CoMD-RHT-AC" ${FLAGS_ALREADY_CONSUMED} 0)
#createExecutable("CoMD-RHT-AC-VG" ${FLAGS_ALREADY_CONSUMED} 1)

# SRMT
#createExecutable("CoMD-RHT-SRMT" ${FLAGS_WANG} 0)
#createExecutable("CoMD-RHT-SRMT-VG" ${FLAGS_SRMT} 1)

# no sync consumer
#createExecutable("CoMD-RHT-NSC" ${FLAGS_NO_SYNC_CONSUMER} 0)
#createExecutable("CoMD-RHT-NSC-VG" ${FLAGS_NO_SYNC_CONSUMER} 1)

# new limit
#createExecutable("CoMD-RHT-NL" ${FLAGS_NEW_LIMIT} 0)
#createExecutable("CoMD-RHT-NL-VG" ${FLAGS_NEW_LIMIT} 1)

# new limit inverted
#createExecutable("CoMD-RHT-NLI" ${FLAGS_NEW_LIMIT_INVERTED} 0)
#createExecutable("CoMD-RHT-NLI-VG" ${FLAGS_NEW_LIMIT_INVERTED} 1)

createExecutable("CoMD-WANG" ${FLAGS_WANG} 0 0 0)
createExecutable("CoMD-WANG-VG-2" ${FLAGS_WANG} 1 0 2)
createExecutable("CoMD-WANG-VG-4" ${FLAGS_WANG} 1 0 4)
createExecutable("CoMD-WANG-VG-8" ${FLAGS_WANG} 1 0 8)
createExecutable("CoMD-WANG-VG-16" ${FLAGS_WANG} 1 0 16)
createExecutable("CoMD-WANG-VG-32" ${FLAGS_WANG} 1 0 32)

# wang approach
#createExecutable("CoMD-WANG" ${FLAGS_WANG} 0 0)
#createExecutable("CoMD-WANG-VG" ${FLAGS_WANG} 1 0)
#createExecutable("CoMD-WANG-JV" ${FLAGS_WANG} 2 0)

#createExecutable("IMP-CoMD-WANG" ${FLAGS_WANG} 0 1)
#createExecutable("IMP-CoMD-WANG-VG" ${FLAGS_WANG} 1 1)
#createExecutable("IMP-CoMD-WANG-JV" ${FLAGS_WANG} 2 1)

# mix wang approach
#createExecutable("CoMD-MIX" ${FLAGS_MIX_WANG} 0)
#createExecutable("CoMD-MIX-VG" ${FLAGS_MIX_WANG} 1)

# mix wang improved approach
#createExecutable("CoMD-MIX-IMP" ${FLAGS_MIX_WANG_IMPROVED} 0)
#createExecutable("CoMD-MIX-IMP-VG" ${FLAGS_MIX_WANG_IMPROVED} 1)

#createExecutable("CoMD-RHT" ${FLAGS_NEW_LIMIT} 1)
