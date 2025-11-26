cmake_minimum_required(VERSION 4.1)

project(battalion
    VERSION 1.4.0
    DESCRIPTION "Monsters, explosions, senseless destruction. You've seen the \
movies, you know what to do."
    HOMEPAGE_URL https://www.evl.uic.edu/aej/AndyBattalion.html
    LANGUAGES C
)

# if using valgrind, set BUILD_WITH_ASAN to OFF
option(BUILD_WITH_ASAN "Build with ASAN" ON)

find_package(X11 REQUIRED)
find_package(OpenGL REQUIRED)

set(target ${PROJECT_NAME})
add_executable(${target})
target_compile_features(${target} PRIVATE c_std_23)
target_compile_definitions(${target} PRIVATE LINUXAUDIO)
target_sources(${target} PRIVATE
    battalion.c
    battalion.h
   
    audio.c
    font.c
    gprim.c
    graphics.c
    net.c
    objects.c
    soundIt.c
    soundIt.h
    text.c
    tk.c
    tk.h
    update.c
)
if(BUILD_WITH_ASAN)
    target_compile_options(${target} PRIVATE -fsanitize=address)
    target_link_options(${target} PRIVATE -fsanitize=address)
endif()
target_link_libraries(${target} PRIVATE OpenGL::GL OpenGL::GLU)
target_link_libraries(${target} PRIVATE X11::X11)
target_link_libraries(${target} PRIVATE m)


# copy assets

set(DATA_DIR "battalion.data")
set(asset_dirs
    DATA
    MUSIC
    SOUNDS
    TEXTURES
)
foreach(dir ${asset_dirs})
add_custom_command(TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/${dir} $<TARGET_FILE_DIR:${target}>/${DATA_DIR}/${dir})    
endforeach()

# create empty hiscore and battalion.sho files

add_custom_command(TARGET ${target} POST_BUILD COMMAND touch $<TARGET_FILE_DIR:${target}>/${DATA_DIR}/battalion.sho)
add_custom_command(TARGET ${target} POST_BUILD COMMAND touch $<TARGET_FILE_DIR:${target}>/battalion_hiscore)

# valgrind target

add_custom_target(valgrind
    COMMAND valgrind
        --leak-check=full
        --show-leak-kinds=all
        --track-origins=yes
        -s --suppressions=${CMAKE_SOURCE_DIR}/battalion.valgrind.supp
        --gen-suppressions=all
        --log-file=${CMAKE_SOURCE_DIR}/dev/logs/memcheck.log
        $<TARGET_FILE:${target}>
    DEPENDS ${target}
    WORKING_DIRECTORY $<TARGET_FILE_DIR:${target}>
    COMMENT "Running battalion with valgrind"
)
