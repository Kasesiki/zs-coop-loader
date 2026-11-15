function loot_decrement_container_amount(arg0, arg1 = 1)
{
    if (arg1 <= 0)
    {
        return undefined;
    }
    arg0.container_amount -= arg1;
    arg0.container_amount = clamp(arg0.container_amount, 0, 99999);
    if (arg0.container_amount <= 0)
    {
        return false;
    }
    else
    {
        return true;
    }
}
