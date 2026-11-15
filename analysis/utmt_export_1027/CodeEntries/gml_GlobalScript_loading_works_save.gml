function loading_works_save(arg0)
{
    loading_works = arg0;
    db_open("local settings");
    db_write("startup", "works", loading_works);
    db_close();
}
