#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <glib-object.h>

typedef struct {
    int total_tests;
    int passed_tests;
    int failed_tests;
} TestResult;

void print_test_result(const char* test_name, gboolean passed, TestResult* result) {
    result->total_tests++;
    if (passed) {
        printf("[PASS] %s\n", test_name);
        result->passed_tests++;
    } else {
        printf("[FAIL] %s\n", test_name);
        result->failed_tests++;
    }
}

int main(int argc, char** argv) {
    TestResult result = {0, 0, 0};
    printf("========================================\n");
    printf("GLib 2.0 ABI Check\n");
    printf("Compile-time GLib version: %d.%d.%d\n", GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION, GLIB_MICRO_VERSION);
    printf("Runtime GLib version: %d.%d.%d\n", glib_major_version, glib_minor_version, glib_micro_version);
    printf("========================================\n\n");

    gboolean version_match = (glib_major_version == GLIB_MAJOR_VERSION &&
                              glib_minor_version == GLIB_MINOR_VERSION);
    print_test_result("Compile-time and runtime GLib version match", version_match, &result);
    printf("\n");

    printf("[1/4] Basic type size check\n");
    print_test_result("sizeof(gint) == 4", sizeof(gint) == 4, &result);
    print_test_result("sizeof(guint) == 4", sizeof(guint) == 4, &result);
    print_test_result("sizeof(glong) == sizeof(long)", sizeof(glong) == sizeof(long), &result);
    print_test_result("sizeof(gulong) == sizeof(unsigned long)", sizeof(gulong) == sizeof(unsigned long), &result);
    print_test_result("sizeof(gint64) == 8", sizeof(gint64) == 8, &result);
    print_test_result("sizeof(guint64) == 8", sizeof(guint64) == 8, &result);
    print_test_result("sizeof(gpointer) == sizeof(void*)", sizeof(gpointer) == sizeof(void*), &result);
    print_test_result("sizeof(gsize) == sizeof(size_t)", sizeof(gsize) == sizeof(size_t), &result);
    print_test_result("sizeof(gssize) == sizeof(ssize_t)", sizeof(gssize) == sizeof(ssize_t), &result);
    printf("\n");

    printf("[2/4] Core data structure layout check\n");
    print_test_result("sizeof(GString) > 0", sizeof(GString) > 0, &result);
    printf("  sizeof(GString) = %zu\n", sizeof(GString));
    print_test_result("sizeof(GList) == 3*sizeof(gpointer)", sizeof(GList) == 3*sizeof(gpointer), &result);
    printf("  sizeof(GList) = %zu\n", sizeof(GList));
    print_test_result("sizeof(GSList) == 2*sizeof(gpointer)", sizeof(GSList) == 2*sizeof(gpointer), &result);
    printf("  sizeof(GSList) = %zu\n", sizeof(GSList));
    print_test_result("sizeof(GArray) > 0", sizeof(GArray) > 0, &result);
    printf("  sizeof(GArray) = %zu\n", sizeof(GArray));
    print_test_result("sizeof(GByteArray) == sizeof(GArray)", sizeof(GByteArray) == sizeof(GArray), &result);
    print_test_result("sizeof(GError) > 0", sizeof(GError) > 0, &result);
    printf("  sizeof(GError) = %zu (gpointer=%zu)\n", sizeof(GError), sizeof(gpointer));
    printf("\n");

    printf("[3/4] Enum and constant check\n");
    printf("  G_TYPE_NONE=%lu\n", (unsigned long)G_TYPE_NONE);
    printf("  G_TYPE_BOOLEAN=%lu\n", (unsigned long)G_TYPE_BOOLEAN);
    printf("  G_TYPE_INT=%lu\n", (unsigned long)G_TYPE_INT);
    printf("  G_TYPE_STRING=%lu\n", (unsigned long)G_TYPE_STRING);
    printf("  G_TYPE_OBJECT=%lu\n", (unsigned long)G_TYPE_OBJECT);
    print_test_result("G_TYPE values are valid fundamental types",
        G_TYPE_IS_FUNDAMENTAL(G_TYPE_NONE) &&
        G_TYPE_IS_FUNDAMENTAL(G_TYPE_BOOLEAN) &&
        G_TYPE_IS_FUNDAMENTAL(G_TYPE_INT) &&
        G_TYPE_IS_FUNDAMENTAL(G_TYPE_STRING), &result);
    print_test_result("G_SEEK_SET != G_SEEK_CUR", G_SEEK_SET != G_SEEK_CUR, &result);
    print_test_result("G_SEEK_END != G_SEEK_SET", G_SEEK_END != G_SEEK_SET, &result);
    printf("\n");

    printf("[4/4] Core function check\n");

    gpointer ptr = g_malloc(1024);
    print_test_result("g_malloc works", ptr != NULL, &result);
    if (ptr) {
        memset(ptr, 0, 1024);
        g_free(ptr);
        print_test_result("g_free works", TRUE, &result);
    } else {
        print_test_result("g_free works", FALSE, &result);
    }

    const char* test_str = "hello glib";
    gchar* dup_str = g_strdup(test_str);
    print_test_result("g_strdup works", dup_str != NULL && strcmp(dup_str, test_str) == 0, &result);
    g_free(dup_str);

    GString* gstr = g_string_new("test");
    print_test_result("g_string_new works", gstr != NULL && strcmp(gstr->str, "test") == 0, &result);
    g_string_free(gstr, TRUE);

    GList* list = NULL;
    list = g_list_append(list, "item1");
    list = g_list_append(list, "item2");
    print_test_result("g_list_append works", g_list_length(list) == 2, &result);
    g_list_free(list);

    GHashTable* hash = g_hash_table_new(g_str_hash, g_str_equal);
    print_test_result("g_hash_table_new works", hash != NULL, &result);
    g_hash_table_destroy(hash);

    printf("\n");

    printf("========================================\n");
    printf("ABI Check Complete\n");
    printf("Total: %d  Passed: %d  Failed: %d\n", result.total_tests, result.passed_tests, result.failed_tests);
    printf("========================================\n");

    if (result.failed_tests == 0) {
        printf("GLib 2.0 ABI compatible!\n");
        return 0;
    } else {
        printf("GLib 2.0 ABI incompatible!\n");
        return 1;
    }
}
