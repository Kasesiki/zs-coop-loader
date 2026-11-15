function loading_works_init()
{
    db_open("local settings");
    loading_works = db_read("startup", "works", true);
    draw_loading_work_tips = !loading_works;
    db_close();
}
