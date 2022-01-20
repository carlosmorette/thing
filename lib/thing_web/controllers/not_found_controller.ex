defmodule ThingWeb.NotFoundController do
  use ThingWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/")
  end
end
