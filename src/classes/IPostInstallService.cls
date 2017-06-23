/**
 * Created by cshah on 5/22/2017.
 */

/**
 * this class is post install script framework
 *
 */

public interface IPostInstallService {
    void startService();
    void executeNextScript();
    void finishService();
    void retry();
}