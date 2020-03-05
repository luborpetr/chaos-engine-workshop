from locust import HttpLocust, TaskSet, task, between


class UserBehaviour(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """

    @task(1)
    def profile(self):
        self.client.get("/")


class WebsiteUser(HttpLocust):
    task_set = UserBehaviour
    wait_time = between(1, 1)
